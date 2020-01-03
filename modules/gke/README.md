# gke

The verified gke module at https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/5.0.0 proved difficult to use due to ServiceAccount, IAM, etc. problems.  So, this is a simplified approach to managing zonal GKE clusters.

I suspect we will outgrow this module.  Perhaps it should be named gke-zonal, but until there's something better...

## Using

The `google-beta` provider must be configured, e.g.

```
provider "google-beta" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = var.credentials
}
```

Call the module.
```
module "gke" {
  source      = "../../modules/gke"
  project_id  = var.project_id
  name        = var.workspace
  labels      = {
    owner = var.owner
    workspace = var.workspace
  }
}
```

Other providers can be configured with module outputs.

```
provider "kubernetes" {
  load_config_file = false
  host = module.gke.host
  cluster_ca_certificate = module.gke.cluster_ca_certificate

  # These login the default service account
  # client_certificate     = module.gke.client_certificate
  # client_key             = module.gke.client_key

  # This logs in the user from GOOGLE_APPLICATION_CREDENTIALS
  # based on configure_kubectl resource in module.gke
  token = "${data.google_client_config.current.access_token}"
}
```

## Variables

See [variables.tf](./variables.tf).

## Outputs

See [outputs.tf](./outputs.tf).
