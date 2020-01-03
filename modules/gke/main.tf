
data "google_client_config" "current" {}

resource "google_container_cluster" "primary" {
  provider = google-beta

  name        = var.name
  description = var.description
  project     = var.project_id

  remove_default_node_pool = true
  initial_node_count       = 1

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""
  }

  resource_labels = var.labels
}

resource "google_container_node_pool" "primary_node_pool" {
  provider = "google-beta"
  name     = "primary"
  cluster  = google_container_cluster.primary.name

  # Finding that destroy takes > 10min default
  timeouts {
    delete = "30m"
  }

  node_config {
    preemptible  = false
    machine_type = "n1-standard-2"
    disk_size_gb = 50

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = var.labels

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_count = 2

  autoscaling {
    min_node_count = 1
    max_node_count = 10
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

resource "null_resource" "configure_kubectl" {
  # Use GOOGLE_APPLICATION_CREDENTIALS user
  provisioner "local-exec" {
    command = "gcloud auth activate-service-account --key-file $${GOOGLE_APPLICATION_CREDENTIALS}"
  }

  # Setup kubectl with current context of new cluster
  provisioner "local-exec" {
    command = "gcloud beta container clusters get-credentials ${var.name}  --zone ${google_container_cluster.primary.location} --project ${var.project_id}"
  }

  # Make GOOGLE_... user a cluster-admin
  provisioner "local-exec" {
    command = "kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)"
  }

  depends_on = ["google_container_cluster.primary"]
}