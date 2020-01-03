terraform {
  backend "gcs" {}
}

provider "google-beta" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = var.credentials
}

module "gke" {
  source     = "../../modules/gke"
  project_id = var.project_id
  name       = var.workspace
  labels = {
    owner     = var.owner
    workspace = var.workspace
  }
}

provider "kubernetes" {
  load_config_file       = false
  host                   = module.gke.host
  cluster_ca_certificate = module.gke.cluster_ca_certificate

  # This logs in the user from GOOGLE_APPLICATION_CREDENTIALS
  # based on configure_kubectl resource in module.gke
  token = module.gke.access_token

  # These login the default service account
  # client_certificate     = module.gke.client_certificate
  # client_key             = module.gke.client_key
}
