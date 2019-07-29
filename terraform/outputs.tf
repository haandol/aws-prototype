output "app_config_map" {
  value = "${local.config_map}"
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
}

output "alb_deployment" {
  value = "${local.alb_deployment}"
}