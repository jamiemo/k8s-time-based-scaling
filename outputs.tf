output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

output "cluster_repo" {
  description = "Cluster ECR URL to upload images."
  value       = aws_ecr_repository.cluster_repo.repository_url
}
