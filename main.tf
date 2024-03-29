provider "aws" {
  alias = "region"
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
    }
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  load_config_file       = false
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_availability_zones" "available" {}

data "aws_region" "current" {
  provider = aws.region
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.24.0"

  cluster_name    = local.name
  cluster_version = "1.23"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  #----------------------------------------------------------------------------------------------------------#
  # Security groups used in this module created by the upstream modules terraform-aws-eks (https://github.com/terraform-aws-modules/terraform-aws-eks).
  #   Upstream module implemented Security groups based on the best practices doc https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html.
  #   So, by default the security groups are restrictive. Users needs to enable rules for specific ports required for App requirement or Add-ons
  #   See the notes below for each rule used in these examples
  #----------------------------------------------------------------------------------------------------------#
  node_security_group_additional_rules = {
    # Extend node-to-node security group rules. Recommended and required for the Add-ons
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    # Recommended outbound traffic for Node groups
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    # Allows Control Plane Nodes to talk to Worker nodes on Karpenter ports.
    # This can be extended further to specific port based on the requirement for others Add-on e.g., metrics-server 4443, spark-operator 8080, etc.
    # Change this according to your security requirements if needed
    ingress_nodes_karpenter_port = {
      description                   = "Cluster API to Nodegroup for Karpenter"
      protocol                      = "tcp"
      from_port                     = 8443
      to_port                       = 8443
      type                          = "ingress"
      source_cluster_security_group = true
    }

    ingress_nodes_matrics_server_port = {
      description                   = "Cluster API to Nodegroup for Metrics Server"
      protocol                      = "tcp"
      from_port                     = 4443
      to_port                       = 4443
      type                          = "ingress"
      source_cluster_security_group = true
    }

    ingress_allow_alb_webhook_access_from_control_plane = {
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  cluster_security_group_additional_rules = {
    ingress_nodes_karpenter_ports_tcp = {
      description                = "Karpenter readiness"
      protocol                   = "tcp"
      from_port                  = 8443
      to_port                    = 8443
      type                       = "ingress"
      source_node_security_group = true
    }
  }
  # Add karpenter.sh/discovery tag so that we can use this as securityGroupSelector in karpenter provisioner
  node_security_group_tags = {
    "karpenter.sh/discovery/${local.name}" = local.name
  }

  # EKS MANAGED NODE GROUPS
  # We recommend to have a MNG to place your critical workloads and add-ons
  # Then rely on Karpenter to scale your workloads
  # You can also make uses on nodeSelector and Taints/tolerations to spread workloads on MNG or Karpenter provisioners
  managed_node_groups = {
    managed_ondemand = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t3.large"]

      subnet_ids   = module.vpc.private_subnets
      max_size     = 4
      desired_size = 2
      min_size     = 1
      update_config = [{
        max_unavailable_percentage = 30
      }]

      k8s_labels = {
        loadtype = "baseload"
      }

      # Launch template configuration
      create_launch_template = true              # false will use the default launch template
      launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or bottlerocket
    }
  }

  iam_role_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]

  tags = local.tags
}

module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.24.0"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_karpenter                     = true
  enable_kubecost                      = true
  enable_metrics_server                = true

  karpenter_node_iam_instance_profile        = module.karpenter.instance_profile_name
  karpenter_enable_spot_termination_handling = true
  karpenter_sqs_queue_arn                    = module.karpenter.queue_arn

  karpenter_helm_config = {
    namespace        = kubernetes_namespace.karpenter.metadata[0].name
    create_namespace = false
    # Collection merge does not work as expected
    # https://github.com/hashicorp/terraform/issues/24236
    values = [
      <<-EOT
          settings:
            aws:
              clusterName: ${module.eks_blueprints.eks_cluster_id}
              clusterEndpoint: ${module.eks_blueprints.eks_cluster_endpoint}
              defaultInstanceProfile: ${module.karpenter.instance_profile_name}
              interruptionQueueName: ${module.karpenter.queue_arn}
          nodeSelector:
            loadtype: baseload
        EOT
    ]
  }

  depends_on = [
    module.eks_blueprints.managed_node_groups
  ]

  tags = local.tags
}

################################################################################
# Karpenter
################################################################################

resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
    labels = {
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }
}

# Creates Karpenter native node termination handler resources and IAM instance profile
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 19.5"

  cluster_name           = module.eks_blueprints.eks_cluster_id
  irsa_oidc_provider_arn = module.eks_blueprints.eks_oidc_provider_arn
  create_irsa            = false # IRSA will be created by the kubernetes-addons module

  tags = local.tags
}

# Creates Launch templates for Karpenter
# Launch template outputs will be used in Karpenter Provisioners yaml files. Checkout this examples/karpenter/provisioners/default_provisioner_with_launch_templates.yaml
module "karpenter_launch_templates" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/launch-templates?ref=v4.24.0"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  launch_template_config = {
    linux = {
      ami                    = data.aws_ami.eks.id
      launch_template_prefix = "karpenter"
      monitoring             = true
      iam_instance_profile   = module.eks_blueprints.managed_node_group_iam_instance_profile_id[0]
      vpc_security_group_ids = [module.eks_blueprints.worker_node_security_group_id]
      block_device_mappings = [
        {
          device_name           = "/dev/xvda"
          volume_type           = "gp3"
          volume_size           = 200
          encrypted             = true
          delete_on_termination = true
        }
      ]
    }

    bottlerocket = {
      ami                    = data.aws_ami.bottlerocket.id
      launch_template_os     = "bottlerocket"
      launch_template_prefix = "bottle"
      iam_instance_profile   = module.eks_blueprints.managed_node_group_iam_instance_profile_id[0]
      vpc_security_group_ids = [module.eks_blueprints.worker_node_security_group_id]
      block_device_mappings = [
        {
          device_name           = "/dev/xvda"
          volume_type           = "gp3"
          volume_size           = 200
          encrypted             = true
          delete_on_termination = true
        }
      ]
    }
  }

  tags = merge(local.tags, { Name = "karpenter" })
}

# Deploying default provisioner and default-lt (using launch template) for Karpenter autoscaler
data "kubectl_path_documents" "karpenter_provisioners" {
  pattern = "${path.module}/provisioners/default_provisioner*.yaml" # without launch template
  vars = {
    azs                     = join(",", local.azs)
    iam-instance-profile-id = "${local.name}-${local.node_group_name}"
    eks-cluster-id          = local.name
    eks-vpc_name            = local.name
  }
}

resource "kubectl_manifest" "karpenter_provisioner" {
  for_each  = toset(data.kubectl_path_documents.karpenter_provisioners.documents)
  yaml_body = each.value

  depends_on = [module.eks_blueprints_kubernetes_addons]
}

#---------------------------------------------------------------
# IAM Roles for Service Accounts to set minReplicas for HPA
#---------------------------------------------------------------

resource "kubernetes_namespace" "kubectl" {
  metadata {
    name = "kubectl"
    labels = {
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }
}

module "irsa" {
  source                      = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/irsa?ref=v4.24.0"
  kubernetes_namespace        = kubernetes_namespace.kubectl.metadata[0].name
  create_kubernetes_namespace = false
  kubernetes_service_account  = "kubectl-hpa"
  irsa_iam_policies           = [aws_iam_policy.hpa_irsa_policy.arn]
  eks_cluster_id              = module.eks_blueprints.eks_cluster_id
  eks_oidc_provider_arn       = module.eks_blueprints.eks_oidc_provider_arn

  depends_on = [
    module.eks_blueprints.managed_node_groups
  ]

  tags = local.tags
}

resource "aws_iam_policy" "hpa_irsa_policy" {
  name        = "${local.name}-kubectl-hpa-irsa-policy"
  path        = "/"
  description = "Allows IAM Roles for Service Accounts to use kubectl to set minReplicas for HPA"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:ListNodegroups",
          "eks:DescribeFargateProfile",
          "eks:DescribeAddonConfiguration",
          "eks:UntagResource",
          "eks:ListTagsForResource",
          "eks:ListAddons",
          "eks:DescribeAddon",
          "eks:ListFargateProfiles",
          "eks:DescribeNodegroup",
          "eks:DescribeIdentityProviderConfig",
          "eks:ListUpdates",
          "eks:DescribeUpdate",
          "eks:TagResource",
          "eks:AccessKubernetesApi",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:DescribeAddonVersions",
          "eks:ListIdentityProviderConfigs"
        ]
        Effect   = "Allow"
        Resource = module.eks_blueprints.eks_cluster_arn
      },
    ]
  })
}

resource "kubernetes_cluster_role_binding" "hpa_irsa_rolebinding" {
  metadata {
    name = "${local.name}-kubectl-hpa-irsa-rolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.hpa_irsa_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "kubectl-hpa"
    namespace = module.irsa.namespace
  }
}

resource "kubernetes_cluster_role" "hpa_irsa_role" {
  metadata {
    name = "${local.name}-kubectl-hpa-irsa-role"
  }

  rule {
    api_groups = ["*"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["get", "list", "watch", "patch"]
  }
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}

resource "aws_ecr_repository" "cluster_repo" {
  name                 = "kubectl"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_ami" "eks" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${module.eks_blueprints.eks_cluster_version}-*"]
  }
}

data "aws_ami" "bottlerocket" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-${module.eks_blueprints.eks_cluster_version}-x86_64-*"]
  }
}

# Use gp3 as default storage class for persistent volumes
resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    type      = "gp3"
    fsType    = "ext4"
    encrypted = "true"
  }
}

# Remove gp2 as default storage class
resource "kubernetes_annotations" "gp2" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = "true"

  metadata {
    name = "gp2"
  }

  annotations = {
    # Modify annotations to remove gp2 as default storage class still reatain the class
    "storageclass.kubernetes.io/is-default-class" = "false"
  }

  depends_on = [
    kubernetes_storage_class.gp3
  ]
}