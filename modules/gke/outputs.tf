
output "client_certificate" {
  value     = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
  sensitive = true
}

output "client_key" {
  value     = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
  sensitive = true
}

output "access_token" {
  value     = "${data.google_client_config.current.access_token}"
  sensitive = true
}

output "host" {
  value     = "${google_container_cluster.primary.endpoint}"
  sensitive = true
}

output "name" {
  value       = var.name
  description = "Name of GKE cluster"
}

output "zone" {
  value = google_container_cluster.primary.zone
}
