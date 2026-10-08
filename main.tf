provider "aws" {
  alias = "region"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  # host                   = module.eks.cluster_endpoint
  # cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  # exec {
  #   api_version = "client.authentication.k8s.io/v1beta1"
  #   command     = "aws"
  #   # This requires the awscli to be installed locally where Terraform is executed
  #   args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  # }
}

provider "helm" {
  # kubernetes = {
  #   host                   = module.eks.cluster_endpoint
  #   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  #   token                  = module.eks.auth.token
  # }

  kubernetes = {
    config_path = "~/.kube/config"
    # host                   = module.eks.cluster_endpoint
    # cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    # exec = {
    #   api_version = "client.authentication.k8s.io/v1beta1"
    #   command     = "aws"
    #   # This requires the awscli to be installed locally where Terraform is executed
    #   args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    # }
  }
}

provider "kubectl" {
  config_path = "~/.kube/config"
  # apply_retry_count      = 10
  # host                   = module.eks.cluster_endpoint
  # cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  # load_config_file       = false
  # exec {
  #   api_version = "client.authentication.k8s.io/v1beta1"
  #   command     = "aws"
  #   # This requires the awscli to be installed locally where Terraform is executed
  #   args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  # }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_availability_zones" "available" {}

data "aws_region" "current" {
  provider = aws.region
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.26.0"

  name                   = local.name
  kubernetes_version     = "1.33"
  endpoint_public_access = true # Backwards compat
  enabled_log_types      = ["api", "audit", "authenticator", "controllerManager", "scheduler"] # Backwards compat

  iam_role_name            = "${local.name}-cluster-role" # Backwards compat
  iam_role_use_name_prefix = false                        # Backwards compat

  kms_key_aliases = [local.name] # Backwards compat

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  authentication_mode = "CONFIG_MAP" # Backwards compat
  endpoint_private_access = false # Backwards compat
  # manage_aws_auth_configmap = true

  # aws_auth_roles = [
  #   {
  #     rolearn  = data.aws_caller_identity.current.arn
  #     username = "me"
  #     groups   = ["system:masters"]
  #   },
  # ]

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
  }

  # Add karpenter.sh/discovery tag so that we can use this as securityGroupSelector in karpenter provisioner
  node_security_group_tags = {
    "karpenter.sh/discovery/${local.name}" = local.name
  }

  eks_managed_node_groups = {
    managed_ondemand = {
      node_group_name            = "managed-ondemand"      # Backwards compat
      node_group_name_prefix     = "managed-ondemand-"     # Backwards compat

      iam_role_name              = "${local.name}-managed-ondemand" # Backwards compat
      iam_role_use_name_prefix   = false                   # Backwards compat
      use_custom_launch_template = false                   # Backwards compat
      ami_type                   = "BOTTLEROCKET_x86_64"

      instance_types = ["t3.large"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      labels = {
        loadtype = "baseload"
      }
    }
  }

  iam_role_additional_policies = {
    "AmazonEC2ContainerRegistryReadOnly" = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "AmazonEBSCSIDriverPolicy" = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

  tags = {
    Blueprint  = local.name
    GithubRepo = "https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest"
  }
}

module "eks_blueprints_kubernetes_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.24.3"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_aws_efs_csi_driver            = true
  # aws_efs_csi_driver_irsa_policies     = [resource.aws_iam_policy.aws_efs_csi_driver_tags.arn]
  enable_metrics_server                = true
  enable_aws_load_balancer_controller  = false

  eks_addons = {
    # Amazon EKS add-ons
    aws-ebs-csi-driver = {
      most_recent              = true
      # service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }

    coredns = {
      most_recent = true
    }

    vpc-cni = {
      most_recent              = true
      # service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }

    # aws_efs_csi_driver = {}
    # aws_efs_csi_driver = {
    #   most_recent              = true
    #   role_policies = [resource.aws_iam_policy.aws_efs_csi_driver_tags.arn]
    # }

    kube-proxy = {
      most_recent              = true
    }

    # Third party add-ons via AWS Marketplace
    kubecost_kubecost = {
      most_recent = true
    }
  }

  # karpenter_node                             = module.karpenter.instance_profile_name
  # karpenter_enable_spot_termination          = true

  # karpenter_helm_config = {
  #   namespace        = kubernetes_namespace.karpenter.metadata[0].name
  #   create_namespace = false
  #   # Collection merge does not work as expected
  #   # https://github.com/hashicorp/terraform/issues/24236
  #   values = [
  #     <<-EOT
  #         settings:
  #           aws:
  #             clusterName: ${module.eks.cluster_id}
  #             clusterEndpoint: ${module.eks.cluster_endpoint}
  #             defaultInstanceProfile: ${module.karpenter.instance_profile_name}
  #             interruptionQueueName: ${module.karpenter.queue_arn}
  #         nodeSelector:
  #           loadtype: baseload
  #       EOT
  #   ]
  # }

  tags = local.tags

}

# EFS CSI
# https://aws.amazon.com/blogs/storage/persistent-storage-for-kubernetes/
# By default each access point created via dynamic provisioning writes files under a different directory on EFS, 
# and each access point writes files to EFS using a different POSIX uid/gid. This enables multiple applications 
# to use the same EFS volume for persistent storage while providing isolation between applications.

# EFS storage class for persistent volumes
resource "kubernetes_storage_class_v1" "efs" {
  metadata {
    name = "efs"
  }

  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap" # Dynamic provisioning
    fileSystemId     = module.efs.id
    directoryPerms   = "700"
  }

  mount_options = [
    "iam"
  ]

  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]
}

module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "~> 2.2.1"

  name                 = "${module.eks.cluster_name}-efs"
  creation_token       = "${module.eks.cluster_name}-efs"
  encrypted            = true
  performance_mode     = "generalPurpose"
  throughput_mode      = "bursting"
  create_backup_policy = true
  enable_backup_policy = true

  # Mount targets / security group
  mount_targets = {
    for k, v in zipmap(local.azs, module.vpc.private_subnets) : k => { subnet_id = v }
  }
  security_group_name        = "${module.eks.cluster_name}-efs"
  security_group_description = "${module.eks.cluster_name} EFS CSI security group"
  security_group_vpc_id      = module.vpc.vpc_id
  security_group_ingress_rules = {
    vpc = {
      # relying on the defaults provided for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_ipv4   = local.vpc_cidr
    }
  }

  tags = local.tags
}

# Workaround for incomplete EFS IAM policy
# https://github.com/aws-ia/terraform-aws-eks-blueprints/issues/1572
resource "aws_iam_policy" "aws_efs_csi_driver_tags" {
  name        = "${module.eks.cluster_name}-efs-csi-tag-policy"
  description = "IAM Policy for AWS EFS CSI Driver Tags"
  policy      = data.aws_iam_policy_document.aws_efs_csi_driver_tags.json
  tags        = local.tags
}

data "aws_iam_policy_document" "aws_efs_csi_driver_tags" {
  statement {
    sid    = "AllowTagResource"
    effect = "Allow"
    resources = [
      module.efs.arn
    ]
    actions = ["elasticfilesystem:TagResource"]

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
}

resource "kubernetes_persistent_volume_claim" "efs_shared_disk" {
  metadata {
    name = "efs-reports"
    namespace = kubernetes_namespace.nginx-demo.metadata[0].name
    labels = {
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }
  spec {
    storage_class_name = "efs"
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
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

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 21.26.0"

  cluster_name           = module.eks.cluster_name
  # irsa_oidc_provider_arn = module.eks.oidc_provider.arn

  # Reuse the managed node IAM role to avoid updating the aws-auth configmap until there are better methods in later versions
  # https://github.com/terraform-aws-modules/terraform-aws-eks/tree/v20.20.0/modules/aws-auth
  # EKS version 1.24 and above
  # enable_pod_identity = false
  # https://aws.amazon.com/blogs/containers/amazon-eks-pod-identity-a-new-way-for-applications-on-eks-to-obtain-iam-credentials/

  create_iam_role                            = true
  node_iam_role_name                         = module.eks.node_iam_role_name
  create_pod_identity_association            = true
  tags                                       = local.tags
  create_instance_profile                    = true
  enable_spot_termination                    = true
  node_iam_role_additional_policies = {
    "AmazonEC2ContainerRegistryReadOnly" = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }
}

# https://karpenter.sh/v1.0/upgrading/upgrade-guide/#crd-upgrades
resource "helm_release" "karpenter-crd" {
  namespace  = kubernetes_namespace.karpenter.metadata[0].name
  name       = "karpenter-crd"
  repository = "oci://public.ecr.aws/karpenter"
  # Rate of unauthenticated image pulls: 1 per second
  # https://docs.aws.amazon.com/AmazonECR/latest/public/public-service-quotas.html
  chart   = "karpenter-crd"
  version = "1.5.3"
  values = [
    <<-EOT
    webhook:
      enabled: true
      serviceName: "karpenter"
      port: 8443
    EOT
  ]
}

resource "helm_release" "karpenter" {
  namespace  = kubernetes_namespace.karpenter.metadata[0].name
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  # Rate of unauthenticated image pulls: 1 per second
  # https://docs.aws.amazon.com/AmazonECR/latest/public/public-service-quotas.html
  chart   = "karpenter"
  version = "1.5.3"
  wait    = false

  values = [
    <<-EOT
    serviceAccount:
      create: true
      annotations: 
        eks.amazonaws.com/role-arn: ${module.karpenter.iam_role_arn}
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    EOT
  ]
  depends_on = [ helm_release.karpenter-crd ]
}

resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1
    kind: EC2NodeClass
    metadata:
      annotations:
        kubectl.kubernetes.io/last-applied-configuration: |
          {"apiVersion":"karpenter.k8s.aws/v1beta1","kind":"EC2NodeClass","metadata":{"annotations":{},"name":"default"},"spec":{"amiFamily":"Bottlerocket","blockDeviceMappings":[{"deviceName":"/dev/xvda","ebs":{"deleteOnTermination":true,"encrypted":true,"iops":3000,"throughput":125,"volumeSize":"25Gi","volumeType":"gp3"}},{"deviceName":"/dev/xvdb","ebs":{"deleteOnTermination":true,"encrypted":true,"iops":3000,"throughput":125,"volumeSize":"200Gi","volumeType":"gp3"}}],"detailedMonitoring":true,"role":"k8s-time-based-scaling-managed-ondemand","securityGroupSelectorTerms":[{"tags":{"karpenter.sh/discovery/k8s-time-based-scaling":"k8s-time-based-scaling"}}],"subnetSelectorTerms":[{"tags":{"Name":"k8s-time-based-scaling-private-*"}}],"tags":{"Name":"karpenter.sh/nodepool/default","karpenter.sh/discovery":"k8s-time-based-scaling"}}}
      finalizers:
      - karpenter.k8s.aws/termination
      generation: 1
      name: default
    spec:
      amiSelectorTerms:
      - alias: bottlerocket@latest
      blockDeviceMappings:
      - deviceName: /dev/xvda
        ebs:
          deleteOnTermination: true
          encrypted: true
          iops: 3000
          throughput: 125
          volumeSize: 25Gi
          volumeType: gp3
      - deviceName: /dev/xvdb
        ebs:
          deleteOnTermination: true
          encrypted: true
          iops: 3000
          throughput: 125
          volumeSize: 200Gi
          volumeType: gp3
      detailedMonitoring: true
      metadataOptions:
        httpEndpoint: enabled
        httpProtocolIPv6: disabled
        httpPutResponseHopLimit: 2
        httpTokens: required
      role: ${module.eks.eks_managed_node_groups.managed_ondemand.iam_role_arn}
      securityGroupSelectorTerms:
      - tags:
          karpenter.sh/discovery/${module.eks.cluster_name}: ${module.eks.cluster_name}
      subnetSelectorTerms:
      - tags:
          Name: "${module.eks.cluster_name}-private-*"
      tags:
        Name: karpenter.sh/nodepool/default
        karpenter.sh/discovery: ${module.eks.cluster_name}
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      annotations:
        compatibility.karpenter.sh/v1beta1-nodeclass-reference: '{"name":"default"}'
        kubectl.kubernetes.io/last-applied-configuration: |
          {"apiVersion":"karpenter.sh/v1beta1","kind":"NodePool","metadata":{"annotations":{},"name":"default"},"spec":{"disruption":{"consolidationPolicy":"WhenUnderutilized"},"limits":{"cpu":200},"template":{"spec":{"metadata":{"labels":{"loadtype":"autoscale"}},"nodeClassRef":{"name":"default"},"requirements":[{"key":"karpenter.sh/capacity-type","operator":"In","values":["spot"]},{"key":"kubernetes.io/arch","operator":"In","values":["amd64"]},{"key":"karpenter.k8s.aws/instance-category","operator":"In","values":["t"]},{"key":"karpenter.k8s.aws/instance-cpu","operator":"In","values":["2"]},{"key":"karpenter.k8s.aws/instance-hypervisor","operator":"In","values":["nitro"]},{"key":"karpenter.k8s.aws/instance-generation","operator":"Gt","values":["2"]}]}}}}
      generation: 1
      name: default
    spec:
      disruption:
        budgets:
        - nodes: 10%
        consolidateAfter: 0s
        consolidationPolicy: WhenEmptyOrUnderutilized
      limits:
        cpu: "200"
      template:
        metadata: {}
        spec:
          expireAfter: 720h
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: default
          requirements:
          - key: karpenter.sh/capacity-type
            operator: In
            values:
            - spot
          - key: kubernetes.io/arch
            operator: In
            values:
            - amd64
          - key: karpenter.k8s.aws/instance-category
            operator: In
            values:
            - t
          - key: karpenter.k8s.aws/instance-cpu
            operator: In
            values:
            - "2"
          - key: karpenter.k8s.aws/instance-hypervisor
            operator: In
            values:
            - nitro
          - key: karpenter.k8s.aws/instance-generation
            operator: Gt
            values:
            - "2"
  YAML

  depends_on = [
    kubectl_manifest.karpenter_node_class
  ]
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

# module "irsa" {
#   source                      = "./irsa"
#   kubernetes_namespace        = kubernetes_namespace.kubectl.metadata[0].name
#   create_kubernetes_namespace = false
#   kubernetes_service_account  = "kubectl-hpa"
#   irsa_iam_policies           = [aws_iam_policy.hpa_irsa_policy.arn]
#   eks_cluster_id              = module.eks.cluster_id
#   eks_oidc_provider_arn       = module.eks.oidc_provider_arn

#   depends_on = [
#     module.eks.managed_node_groups
#   ]

#   tags = local.tags
# }

module "irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"

  name = "kubectl-hpa"

  policies = {
    "kubectl-hpa" = aws_iam_policy.hpa_irsa_policy.arn
  }

  oidc_providers = {
    this = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${kubernetes_namespace.kubectl.metadata[0].name}:kubectl-hpa"]
    }
  }

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
        Resource = module.eks.cluster_id
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
    namespace = kubernetes_namespace.kubectl.metadata[0].name
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
  version = "v5.21.0"

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

data "aws_ami" "bottlerocket" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-${module.eks.cluster_version}-x86_64-*"]
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