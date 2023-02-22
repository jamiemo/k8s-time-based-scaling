#---------------------------------------------------------------
# CronJobs to scale minReplicas up and down
#---------------------------------------------------------------

module "nginx_scale_up" {
  source = "./scale-hpa-replicas"
  name ="nginx-scale-up"
  horizontal-pod-autoscaler-name = local.demo_name
  namespace = module.irsa.namespace
  schedule = "0,20,40 * * * *"
  min-replicas = 10
  kubectl-repo = aws_ecr_repository.cluster_repo.repository_url
  service-account-name = "kubectl-hpa"
}

module "nginx_scale_down" {
  source = "./scale-hpa-replicas"
  name ="nginx-scale-down"
  horizontal-pod-autoscaler-name = local.demo_name
  namespace = module.irsa.namespace
  schedule = "10,30,50 * * * *"
  min-replicas = 2
  kubectl-repo = aws_ecr_repository.cluster_repo.repository_url
  service-account-name = "kubectl-hpa"
}