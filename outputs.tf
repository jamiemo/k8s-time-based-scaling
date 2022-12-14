output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

output "cluster_repo" {
  description = "Cluster ECR URL to upload images."
  value       = aws_ecr_repository.cluster_repo.repository_url
}

output "ecr_authentication" {
  description = "Cluster ECR authentication command for uploads."
  value       = "aws ecr get-login-password --region ${local.region} | docker login --username AWS --password-stdin ${split("/", aws_ecr_repository.cluster_repo.repository_url)[0]}"
}

output "docker_image" {
  description = "Build and push custom image for IAM Roles for Service Accounts authentication for kubectl."
  value       = "docker build -t ${aws_ecr_repository.cluster_repo.repository_url} -t kubectl --build-arg aws_region=${local.region} --build-arg cluster_name=${local.name} . && docker push ${aws_ecr_repository.cluster_repo.repository_url}"
}