resource "helm_release" "kube_prometheus" {
  name       = "kube-prometheus"

  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace  = "kube-prometheus"
  create_namespace = true
  depends_on = [ module.eks ]

}