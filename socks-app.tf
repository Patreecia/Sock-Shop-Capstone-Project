resource "helm_release" "socks_app" {
  name       = "socks-app"
  chart      = "./helm-chart"
  namespace  = "socks-app"
  create_namespace = true 
  wait     = false 

  depends_on = [ module.eks ]
}