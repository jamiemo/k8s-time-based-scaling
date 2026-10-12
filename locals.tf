locals {
  name   = basename(path.cwd)
  region = data.aws_region.current.region

  node_group_name = "managed-ondemand"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest"
  }

  demo_name      = "nginx-demo"
  demo_namespace = "nginx-demo"
}
