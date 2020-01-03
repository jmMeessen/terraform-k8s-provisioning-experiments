resource "kubernetes_namespace" "cloudbees-core" {
  metadata {
    name = "cloudbees-core"
  }

  depends_on = ["module.gke"]
}

data "helm_repository" "cloudbees" {
  name = "cloudbees"
  url  = "https://charts.cloudbees.com/public/cloudbees"

  depends_on = ["module.gke"]
}

resource "helm_release" "cloudbees-core" {
  name       = "cloudbees-core"
  repository = data.helm_repository.cloudbees.metadata.0.name
  chart      = "cloudbees/cloudbees-core"
  namespace  = "cloudbees-core"

  set {
    name  = "namespace"
    value = "core"
  }

  set {
    name  = "name"
    value = "cloudbees-core"
  }

  set {
    name  = "OperationsCenter.ServiceType"
    value = "ClusterIP"
  }

  set {
    name  = "OperationsCenter.HostName"
    value = "${data.external.ingress_ip.result["ip"]}.beesdns.com"
  }

  depends_on = ["kubernetes_namespace.cloudbees-core"]
}

resource "null_resource" "echo_url" {
  provisioner "local-exec" {
    command = "echo http://${data.external.ingress_ip.result["ip"]}.beesdns.com/cjoc"
  }

  depends_on = ["helm_release.cloudbees-core"]
}
