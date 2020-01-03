resource "helm_release" "nginx-ingress" {
  name      = "nginx-ingress"
  chart     = "stable/nginx-ingress"
  namespace = "ingress-nginx"

  depends_on = [
    "module.gke",
    "kubernetes_cluster_role_binding.tiller",
  ]
}

# Wait for GKE to assign ingress loadBalancer ip
resource "null_resource" "loadbalancer_delay" {
  provisioner "local-exec" {
    command = "until kubectl get svc -n ingress-nginx -o json | jq -e '.items[0].status.loadBalancer.ingress[0].ip'; do sleep 10; done"
  }

  depends_on = ["helm_release.nginx-ingress"]
}

data "external" "ingress_ip" {
  program    = ["/bin/bash", "-c", "kubectl get svc -n ingress-nginx -o json | jq '.items[0].status.loadBalancer.ingress[0]'"]
  depends_on = ["null_resource.loadbalancer_delay"]
}
