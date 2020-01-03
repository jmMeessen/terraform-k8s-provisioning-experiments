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
  name       = "incubator-tf-test"
  labels = {
    owner     = var.owner
    workspace = var.workspace
  }
}
