provider "helm" {
  kubernetes {
    host = module.gke.host

    client_certificate     = module.gke.client_certificate
    client_key             = module.gke.client_key
    cluster_ca_certificate = module.gke.cluster_ca_certificate
  }
  install_tiller  = true
  service_account = "tiller"
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }

  subject {
    kind = "User"
    name = "system:serviceaccount:kube-system:tiller"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}

/* Seems unecessary, but leaving for future reference
// https://github.com/terraform-providers/terraform-provider-helm/issues/148
resource "null_resource" "helm_init" {
  provisioner "local-exec" {
    command = "docker run --rm -v $(pwd):/apps -v ~/.kube:/root/.kube -v ~/.helm:/root/.helm alpine/helm init --service-account tiller --wait"
  }
  depends_on = [ "kubernetes_cluster_role_binding.tiller" ]
}
*/
