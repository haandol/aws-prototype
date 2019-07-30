output "app_configmap" {
  value = "${local.app_configmap}"
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

output "aws_auth_configmap" {
  value = "${local.aws_auth_configmap}"
}

output "alb_deployment" {
  value = "${local.alb_deployment}"
}