# AWS EKS Blurpeint Migration v4 to v5
The terraform state needs to be migrated to avoid deleting and re-creating resources.

## Initial Changes
```bash
  # module.eks.data.aws_eks_addon_version.this["vpc-cni"] will be read during apply
  # module.eks.data.tls_certificate.this[0] will be read during apply
  # module.eks.aws_cloudwatch_log_group.this[0] will be created
  # module.eks.aws_ec2_tag.cluster_primary_security_group["Blueprint"] will be created
  # module.eks.aws_ec2_tag.cluster_primary_security_group["GithubRepo"] will be created
  # module.eks.aws_eks_addon.before_compute["vpc-cni"] will be created
  # module.eks.aws_eks_cluster.this[0] will be created
  # module.eks.aws_iam_openid_connect_provider.oidc_provider[0] will be created
  # module.eks.aws_iam_policy.cluster_encryption[0] will be created
  # module.eks.aws_iam_role.this[0] will be created
  # module.eks.aws_iam_role_policy_attachment.additional["AmazonEBSCSIDriverPolicy"] will be created
  # module.eks.aws_iam_role_policy_attachment.additional["AmazonEC2ContainerRegistryReadOnly"] will be created
  # module.eks.aws_iam_role_policy_attachment.additional["AmazonEKS_CNI_Policy"] will be created
  # module.eks.aws_iam_role_policy_attachment.cluster_encryption[0] will be created
  # module.eks.aws_iam_role_policy_attachment.this["AmazonEKSClusterPolicy"] will be created
  # module.eks.aws_security_group.cluster[0] will be created
  # module.eks.aws_security_group.node[0] will be created
  # module.eks.aws_security_group_rule.cluster["ingress_nodes_443"] will be created
  # module.eks.aws_security_group_rule.node["egress_all"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_10251_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_443"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_4443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_6443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_8443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_9443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_kubelet"] will be created
  # module.eks.aws_security_group_rule.node["ingress_nodes_ephemeral"] will be created
  # module.eks.aws_security_group_rule.node["ingress_nodes_matrics_server_port"] will be created
  # module.eks.aws_security_group_rule.node["ingress_self_all"] will be created
  # module.eks.aws_security_group_rule.node["ingress_self_coredns_tcp"] will be created
  # module.eks.aws_security_group_rule.node["ingress_self_coredns_udp"] will be created
  # module.eks.time_sleep.this[0] will be created
  # module.eks_blueprints.kubernetes_config_map.aws_auth[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.aws_cloudformation_stack.usage_telemetry[0] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["aws-ebs-csi-driver"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["aws-efs-csi-driver"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["coredns"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["eks-pod-identity-agent"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["kube-proxy"] will be created
  # module.eks_blueprints_kubernetes_addons.random_bytes.this will be created
  # module.eks_blueprints_kubernetes_addons.time_sleep.dataplane will be destroyed
  # module.eks_blueprints_kubernetes_addons.time_sleep.this will be created
  # module.eks.module.eks_managed_node_group["managed_ondemand"].aws_eks_node_group.this[0] will be created
  # module.eks.module.eks_managed_node_group["managed_ondemand"].aws_iam_role.this[0] will be created
  # module.eks.module.eks_managed_node_group["managed_ondemand"].aws_iam_role_policy_attachment.this["AmazonEC2ContainerRegistryReadOnly"] will be created
  # module.eks.module.eks_managed_node_group["managed_ondemand"].aws_iam_role_policy_attachment.this["AmazonEKSWorkerNodePolicy"] will be created
  # module.eks.module.eks_managed_node_group["managed_ondemand"].aws_iam_role_policy_attachment.this["AmazonEKS_CNI_Policy"] will be created
  # module.eks.module.kms.data.aws_iam_policy_document.this[0] will be read during apply
  # module.eks.module.kms.aws_kms_alias.this["cluster"] will be created
  # module.eks.module.kms.aws_kms_alias.this["k8s-time-based-scaling"] will be created
  # module.eks.module.kms.aws_kms_key.this[0] will be created
  # module.eks_blueprints.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["Blueprint"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["GithubRepo"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_iam_openid_connect_provider.oidc_provider[0] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_iam_role.this[0] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group.cluster[0] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group.node[0] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["egress_nodes_443"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["egress_nodes_kubelet"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["ingress_nodes_443"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["ingress_nodes_karpenter_ports_tcp"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_all"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_cluster_443"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_https"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_ntp_tcp"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_ntp_udp"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_self_coredns_tcp"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_self_coredns_udp"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_allow_alb_webhook_access_from_control_plane"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_cluster_443"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_cluster_kubelet"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_nodes_karpenter_port"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_nodes_matrics_server_port"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_self_all"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_self_coredns_tcp"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_self_coredns_udp"] will be destroyed
  # module.eks_blueprints.module.aws_eks_managed_node_groups["managed_ondemand"].aws_eks_node_group.managed_ng will be destroyed
  # module.eks_blueprints.module.aws_eks_managed_node_groups["managed_ondemand"].aws_iam_instance_profile.managed_ng[0] will be destroyed
  # module.eks_blueprints.module.aws_eks_managed_node_groups["managed_ondemand"].aws_iam_role.managed_ng[0] will be destroyed
  # module.eks_blueprints.module.aws_eks_managed_node_groups["managed_ondemand"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"] will be destroyed
  # module.eks_blueprints.module.aws_eks_managed_node_groups["managed_ondemand"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"] will be destroyed
  # module.eks_blueprints.module.aws_eks_managed_node_groups["managed_ondemand"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"] will be destroyed
  # module.eks_blueprints.module.aws_eks_managed_node_groups["managed_ondemand"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"] will be destroyed
  # module.eks_blueprints.module.aws_eks_managed_node_groups["managed_ondemand"].aws_launch_template.managed_node_groups[0] will be destroyed
  # module.eks_blueprints.module.kms[0].aws_kms_alias.this will be destroyed
  # module.eks_blueprints.module.kms[0].aws_kms_key.this will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_coredns[0].aws_eks_addon.coredns[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_coredns[0].time_sleep.this will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_ebs_csi_driver[0].aws_eks_addon.aws_ebs_csi_driver[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_ebs_csi_driver[0].aws_iam_policy.aws_ebs_csi_driver[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.data.aws_iam_policy_document.assume[0] will be read during apply
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.aws_iam_policy.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.aws_iam_role.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.aws_iam_role_policy_attachment.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.helm_release.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].aws_iam_policy.aws_efs_csi_driver will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_kube_proxy[0].aws_eks_addon.kube_proxy will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_vpc_cni[0].aws_eks_addon.vpc_cni will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.metrics_server.helm_release.this[0] will be created
  # module.eks.module.eks_managed_node_group["managed_ondemand"].module.user_data.null_resource.validate_cluster_service_cidr will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_ebs_csi_driver[0].module.irsa_addon[0].aws_iam_role.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_ebs_csi_driver[0].module.irsa_addon[0].aws_iam_role_policy_attachment.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.helm_release.addon[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_vpc_cni[0].module.irsa_addon[0].aws_iam_role.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_vpc_cni[0].module.irsa_addon[0].aws_iam_role_policy_attachment.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.kube_state_metrics[0].module.helm_addon.helm_release.addon[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.metrics_server[0].module.helm_addon.helm_release.addon[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_coredns[0].module.cluster_proportional_autoscaler[0].module.helm_addon.helm_release.addon[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.module.irsa[0].aws_iam_role.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.module.irsa[0].aws_iam_role_policy_attachment.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.module.irsa[0].aws_iam_role_policy_attachment.irsa[1] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.module.irsa[0].kubernetes_service_account_v1.irsa[0] will be destroyed
  ```

## Migrate 
```bash
terraform init -upgrade
```

[Cluster](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/docs/v4-to-v5/cluster.md#upgrade-migrations)
```bash
# This is not removing the configmap from the cluster - it will be adopted by the new module
terraform state rm 'module.eks_blueprints.kubernetes_config_map.aws_auth[0]'

# Cluster
terraform state mv 'module.eks_blueprints.module.aws_eks.aws_eks_cluster.this[0]' 'module.eks.aws_eks_cluster.this[0]'

# Cluster IAM role
terraform state mv 'module.eks_blueprints.module.aws_eks.aws_iam_role.this[0]' 'module.eks.aws_iam_role.this[0]'
terraform state mv 'module.eks_blueprints.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]' 'module.eks.aws_iam_role_policy_attachment.this["AmazonEKSClusterPolicy"]'
terraform state mv 'module.eks_blueprints.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"]' 'module.eks.aws_iam_role_policy_attachment.this["AmazonEKSVPCResourceController"]'

# Cluster primary security group tags
# Note: This will depend on the tags applied to the module - here we
#       are demonstrating the two tags used in the configuration above
terraform state mv 'module.eks_blueprints.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["Blueprint"]' 'module.eks.aws_ec2_tag.cluster_primary_security_group["Blueprint"]'
terraform state mv 'module.eks_blueprints.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["GithubRepo"]' 'module.eks.aws_ec2_tag.cluster_primary_security_group["GithubRepo"]'

# Cluster security group
terraform state mv 'module.eks_blueprints.module.aws_eks.aws_security_group.cluster[0]' 'module.eks.aws_security_group.cluster[0]'

# Cluster security group rules
terraform state mv 'module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["ingress_nodes_443"]' 'module.eks.aws_security_group_rule.cluster["ingress_nodes_443"]'

# Node security group
terraform state mv 'module.eks_blueprints.module.aws_eks.aws_security_group.node[0]' 'module.eks.aws_security_group.node[0]'

# Node security group rules
terraform state mv 'module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_cluster_443"]' 'module.eks.aws_security_group_rule.node["ingress_cluster_443"]'
terraform state mv 'module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_cluster_kubelet"]' 'module.eks.aws_security_group_rule.node["ingress_cluster_kubelet"]'
terraform state mv 'module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_self_coredns_tcp"]' 'module.eks.aws_security_group_rule.node["ingress_self_coredns_tcp"]'
terraform state mv 'module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_self_coredns_udp"]' 'module.eks.aws_security_group_rule.node["ingress_self_coredns_udp"]'

# OIDC provider
terraform state mv 'module.eks_blueprints.module.aws_eks.aws_iam_openid_connect_provider.oidc_provider[0]' 'module.eks.aws_iam_openid_connect_provider.oidc_provider[0]'

# Managed nodegroup(s)
# Note: This demonstrates migrating one nodegroup that is stored under the
#       key `managed` in the module definition. The same set of steps would
#       need to be performed for each nodegroup, changing only the key name
terraform state mv 'module.eks_blueprints.module.aws_eks_managed_node_groups["managed_ondemand"].aws_eks_node_group.managed_ng' 'module.eks.module.eks_managed_node_group["managed_ondemand"].aws_eks_node_group.this[0]'
terraform state mv 'module.eks_blueprints.module.aws_eks_managed_node_groups["managed_ondemand"].aws_iam_role.managed_ng[0]' 'module.eks.module.eks_managed_node_group["managed_ondemand"].aws_iam_role.this[0]'
terraform state mv 'module.eks_blueprints.module.aws_eks_managed_node_groups["managed_ondemand"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]' 'module.eks.module.eks_managed_node_group["managed_ondemand"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]'
terraform state mv 'module.eks_blueprints.module.aws_eks_managed_node_groups["managed_ondemand"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]' 'module.eks.module.eks_managed_node_group["managed_ondemand"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]'
terraform state mv 'module.eks_blueprints.module.aws_eks_managed_node_groups["managed_ondemand"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]' 'module.eks.module.eks_managed_node_group["managed_ondemand"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]'

# Secrets KMS key
terraform state mv 'module.eks_blueprints.module.kms[0].aws_kms_key.this' 'module.eks.module.kms.aws_kms_key.this[0]'
terraform state mv 'module.eks_blueprints.module.kms[0].aws_kms_alias.this' 'module.eks.module.kms.aws_kms_alias.this["migration"]'

# Cloudwatch Log Group
# terraform import 'module.eks_blueprints.aws_cloudwatch_log_group.this[0]' 'module.eks.aws_cloudwatch_log_group.this[0]'
# terraform import 'module.eks.aws_cloudwatch_log_group.this[0]' '/aws/eks/k8s-time-based-scaling/cluster'
# If the CloudWatch Log Group fails to import, disable logging on the cluster and delete existing CloudWatch Log Group

[Addons](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/docs/v4-to-v5/addons.md#upgrade-migrations)

 # module.eks_blueprints_kubernetes_addons.aws_cloudformation_stack.usage_telemetry[0] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["aws-ebs-csi-driver"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["coredns"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["eks-pod-identity-agent"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["kube-proxy"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["vpc-cni"] will be created
  # module.eks_blueprints_kubernetes_addons.random_bytes.this will be created
  # module.eks_blueprints_kubernetes_addons.time_sleep.dataplane will be destroyed
  # module.eks_blueprints_kubernetes_addons.time_sleep.this will be created

  # module.eks_blueprints_kubernetes_addons.module.aws_coredns[0].aws_eks_addon.coredns[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_coredns[0].time_sleep.this will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_ebs_csi_driver[0].aws_eks_addon.aws_ebs_csi_driver[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_ebs_csi_driver[0].aws_iam_policy.aws_ebs_csi_driver[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.data.aws_iam_policy_document.assume[0] will be read during apply
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.aws_iam_policy.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.aws_iam_role.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.aws_iam_role_policy_attachment.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.helm_release.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].aws_iam_policy.aws_efs_csi_driver will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_kube_proxy[0].aws_eks_addon.kube_proxy will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_vpc_cni[0].aws_eks_addon.vpc_cni will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.metrics_server.helm_release.this[0] will be created
  # module.eks.module.eks_managed_node_group["managed_ondemand"].module.user_data.null_resource.validate_cluster_service_cidr will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_ebs_csi_driver[0].module.irsa_addon[0].aws_iam_role.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_ebs_csi_driver[0].module.irsa_addon[0].aws_iam_role_policy_attachment.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.helm_release.addon[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_vpc_cni[0].module.irsa_addon[0].aws_iam_role.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_vpc_cni[0].module.irsa_addon[0].aws_iam_role_policy_attachment.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.kube_state_metrics[0].module.helm_addon.helm_release.addon[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.metrics_server[0].module.helm_addon.helm_release.addon[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_coredns[0].module.cluster_proportional_autoscaler[0].module.helm_addon.helm_release.addon[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.module.irsa[0].aws_iam_role.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.module.irsa[0].aws_iam_role_policy_attachment.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.module.irsa[0].aws_iam_role_policy_attachment.irsa[1] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.module.irsa[0].kubernetes_service_account_v1.irsa[0] will be destroyed

terraform state mv 'module.eks_blueprints_kubernetes_addons.module.aws_coredns[0].aws_eks_addon.coredns[0]' 'module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["coredns"]'
# VPC CNI dependency for Managed Node Group is re-created
# terraform state mv 'module.eks_blueprints_kubernetes_addons.module.aws_vpc_cni[0].aws_eks_addon.vpc_cni' 'module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["vpc-cni"]'
terraform state mv 'module.eks_blueprints_kubernetes_addons.module.aws_kube_proxy[0].aws_eks_addon.kube_proxy' 'module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["kube-proxy"]'
terraform state mv 'module.eks_blueprints_kubernetes_addons.module.aws_ebs_csi_driver[0].aws_eks_addon.aws_ebs_csi_driver[0]' 'module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["aws-ebs-csi-driver"]'

# terraform state mv 'module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].aws_iam_policy.aws_efs_csi_driver' 'module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.aws_iam_policy.this[0]'
# terraform state mv 'module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.helm_release.addon[0]' 'module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.helm_release.this[0]'
# terraform state mv 'module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.module.irsa[0].aws_iam_role.irsa[0]' 'module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.aws_iam_role.this[0]'

# terraform state mv 'module.eks_blueprints_kubernetes_addons.module.metrics_server[0].module.helm_addon.helm_release.addon[0]' 'module.eks_blueprints_kubernetes_addons.module.metrics_server.helm_release.this[0]'

## Final Changes
```bash
  # module.eks.aws_eks_cluster.this[0] has changed
  # module.eks.module.kms.aws_kms_key.this[0] has changed
  # module.eks.data.aws_eks_addon_version.this["vpc-cni"] will be read during apply
  # module.eks.data.tls_certificate.this[0] will be read during apply
  # module.eks.aws_cloudwatch_log_group.this[0] will be created
  # module.eks.aws_ec2_tag.cluster_primary_security_group["GithubRepo"] will be updated in-place
  # module.eks.aws_eks_addon.before_compute["vpc-cni"] will be created
  # module.eks.aws_eks_cluster.this[0] will be updated in-place
  # module.eks.aws_iam_openid_connect_provider.oidc_provider[0] will be updated in-place
  # module.eks.aws_iam_policy.cluster_encryption[0] will be created
  # module.eks.aws_iam_role.this[0] will be updated in-place
  # module.eks.aws_iam_role_policy_attachment.additional["AmazonEBSCSIDriverPolicy"] will be created
  # module.eks.aws_iam_role_policy_attachment.additional["AmazonEC2ContainerRegistryReadOnly"] will be created
  # module.eks.aws_iam_role_policy_attachment.additional["AmazonEKS_CNI_Policy"] will be created
  # module.eks.aws_iam_role_policy_attachment.cluster_encryption[0] will be created
  # module.eks.aws_iam_role_policy_attachment.this["AmazonEKSVPCResourceController"] will be destroyed
  # module.eks.aws_security_group.cluster[0] will be updated in-place
  # module.eks.aws_security_group.node[0] will be updated in-place
  # module.eks.aws_security_group_rule.node["egress_all"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_10251_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_4443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_6443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_8443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_9443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_nodes_ephemeral"] will be created
  # module.eks.aws_security_group_rule.node["ingress_nodes_matrics_server_port"] will be created
  # module.eks.aws_security_group_rule.node["ingress_self_all"] will be created
  # module.eks.aws_security_group_rule.node["ingress_self_coredns_udp"] will be updated in-place
  # module.eks.time_sleep.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.aws_cloudformation_stack.usage_telemetry[0] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["aws-ebs-csi-driver"] will be updated in-place
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["aws-efs-csi-driver"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["coredns"] will be updated in-place
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["eks-pod-identity-agent"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["kube-proxy"] will be updated in-place
  # module.eks_blueprints_kubernetes_addons.random_bytes.this will be created
  # module.eks_blueprints_kubernetes_addons.time_sleep.dataplane will be destroyed
  # module.eks_blueprints_kubernetes_addons.time_sleep.this will be created
  # module.eks.module.eks_managed_node_group["managed_ondemand"].aws_eks_node_group.this[0] must be replaced
  # module.eks.module.eks_managed_node_group["managed_ondemand"].aws_iam_role.this[0] will be updated in-place
  # module.eks.module.eks_managed_node_group["managed_ondemand"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"] has moved to module.eks.module.eks_managed_node_group["managed_ondemand"].aws_iam_role_policy_attachment.this["AmazonEC2ContainerRegistryReadOnly"]
  # module.eks.module.eks_managed_node_group["managed_ondemand"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"] has moved to module.eks.module.eks_managed_node_group["managed_ondemand"].aws_iam_role_policy_attachment.this["AmazonEKSWorkerNodePolicy"]
  # module.eks.module.eks_managed_node_group["managed_ondemand"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"] has moved to module.eks.module.eks_managed_node_group["managed_ondemand"].aws_iam_role_policy_attachment.this["AmazonEKS_CNI_Policy"]
  # module.eks.module.kms.aws_kms_alias.this["cluster"] will be created
  # module.eks.module.kms.aws_kms_alias.this["k8s-time-based-scaling"] will be created
  # module.eks.module.kms.aws_kms_alias.this["migration"] will be destroyed
  # module.eks.module.kms.aws_kms_key.this[0] will be updated in-place
  # module.eks_blueprints.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["egress_nodes_443"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["egress_nodes_kubelet"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.cluster["ingress_nodes_karpenter_ports_tcp"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_all"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_cluster_443"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_https"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_ntp_tcp"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_ntp_udp"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_self_coredns_tcp"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["egress_self_coredns_udp"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_allow_alb_webhook_access_from_control_plane"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_nodes_karpenter_port"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_nodes_matrics_server_port"] will be destroyed
  # module.eks_blueprints.module.aws_eks.aws_security_group_rule.node["ingress_self_all"] will be destroyed
  # module.eks_blueprints.module.aws_eks_managed_node_groups["managed_ondemand"].aws_iam_instance_profile.managed_ng[0] will be destroyed
  # module.eks_blueprints.module.aws_eks_managed_node_groups["managed_ondemand"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"] will be destroyed
  # module.eks_blueprints.module.aws_eks_managed_node_groups["managed_ondemand"].aws_launch_template.managed_node_groups[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_coredns[0].time_sleep.this will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_ebs_csi_driver[0].aws_iam_policy.aws_ebs_csi_driver[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.aws_iam_policy.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.aws_iam_role.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.aws_iam_role_policy_attachment.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.helm_release.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].aws_iam_policy.aws_efs_csi_driver will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_vpc_cni[0].aws_eks_addon.vpc_cni will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.metrics_server.helm_release.this[0] will be created
  # module.eks.module.eks_managed_node_group["managed_ondemand"].module.user_data.null_resource.validate_cluster_service_cidr will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_ebs_csi_driver[0].module.irsa_addon[0].aws_iam_role.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_ebs_csi_driver[0].module.irsa_addon[0].aws_iam_role_policy_attachment.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.helm_release.addon[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_vpc_cni[0].module.irsa_addon[0].aws_iam_role.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_vpc_cni[0].module.irsa_addon[0].aws_iam_role_policy_attachment.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.kube_state_metrics[0].module.helm_addon.helm_release.addon[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.metrics_server[0].module.helm_addon.helm_release.addon[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_coredns[0].module.cluster_proportional_autoscaler[0].module.helm_addon.helm_release.addon[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.module.irsa[0].aws_iam_role.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.module.irsa[0].aws_iam_role_policy_attachment.irsa[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.module.irsa[0].aws_iam_role_policy_attachment.irsa[1] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver[0].module.helm_addon.module.irsa[0].kubernetes_service_account_v1.irsa[0] will be destroyed
```

## EC2 Node Class
This will detele all Karpenter created nodes while they are re-created, due to the immutable role field.

```bash
Error: default failed to run apply: error when applying patch:
│ {"metadata":{"annotations":{"kubectl.kubernetes.io/last-applied-configuration":"{\"apiVersion\":\"karpenter.k8s.aws/v1\",\"kind\":\"EC2NodeClass\",\"metadata\":{\"annotations\":{},\"finalizers\":[\"karpenter.k8s.aws/termination\"],\"generation\":1,\"name\":\"default\"},\"spec\":{\"amiSelectorTerms\":[{\"alias\":\"bottlerocket@latest\"}],\"blockDeviceMappings\":[{\"deviceName\":\"/dev/xvda\",\"ebs\":{\"deleteOnTermination\":true,\"encrypted\":true,\"iops\":3000,\"throughput\":125,\"volumeSize\":\"25Gi\",\"volumeType\":\"gp3\"}},{\"deviceName\":\"/dev/xvdb\",\"ebs\":{\"deleteOnTermination\":true,\"encrypted\":true,\"iops\":3000,\"throughput\":125,\"volumeSize\":\"200Gi\",\"volumeType\":\"gp3\"}}],\"detailedMonitoring\":true,\"metadataOptions\":{\"httpEndpoint\":\"enabled\",\"httpProtocolIPv6\":\"disabled\",\"httpPutResponseHopLimit\":2,\"httpTokens\":\"required\"},\"role\":\"Karpenter-k8s-time-based-scaling-58e108c4c5bf3e53a00dde9809\",\"securityGroupSelectorTerms\":[{\"tags\":{\"karpenter.sh/discovery/k8s-time-based-scaling\":\"k8s-time-based-scaling\"}}],\"subnetSelectorTerms\":[{\"tags\":{\"Name\":\"k8s-time-based-scaling-private-*\"}}],\"tags\":{\"Name\":\"karpenter.sh/nodepool/default\",\"karpenter.sh/discovery\":\"k8s-time-based-scaling\"}}}\n"}},"spec":{"role":"Karpenter-k8s-time-based-scaling-58e108c4c5bf3e53a00dde9809"}}
│ to:
│ Resource: "karpenter.k8s.aws/v1, Resource=ec2nodeclasses", GroupVersionKind: "karpenter.k8s.aws/v1, Kind=EC2NodeClass"
│ Name: "default", Namespace: ""
│ for: "/var/folders/55/nnwyhfkj4334xyl46v7l12300000gn/T/3585361028kubectl_manifest.yaml": error when patching "/var/folders/55/nnwyhfkj4334xyl46v7l12300000gn/T/3585361028kubectl_manifest.yaml": EC2NodeClass.karpenter.k8s.aws "default" is invalid: spec.role: Invalid value: "string": immutable field changed
│ 
│   with kubectl_manifest.karpenter_node_class,
│   on main.tf line 551, in resource "kubectl_manifest" "karpenter_node_class":
│  551: resource "kubectl_manifest" "karpenter_node_class" {
│ 
╵
╷
│ Error: creating EKS Add-On (k8s-time-based-scaling:aws-ebs-csi-driver): operation error EKS: CreateAddon, https response error StatusCode: 409, RequestID: 1e09e748-4d4e-4842-be5c-dd8933216b8f, ResourceInUseException: Addon already exists.
│ 
│   with module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["aws-ebs-csi-driver"],
│   on .terraform/modules/eks_blueprints_kubernetes_addons/main.tf line 2427, in resource "aws_eks_addon" "this":
│ 2427: resource "aws_eks_addon" "this" {
```
### Delete EC2NodeClass and NodePool
This resets the immutable field role, and also removes the AWS_ROLE_ARN annotation used by IRSA.

```bash
kubectl edit EC2NodeClass default
```
Delete the `karpenter.k8s.aws/termination` finalizer.

```bash
kubectl delete nodepool default --force -no-wait
kubectl delete EC2NodeClass default --force -no-wait
```

### Prepare to Move to kube-system Namespace
```bash
helm uninstall karpenter -n karpenter
helm uninstall karpenter-crd -n karpenter
kubectl annotate crd nodeclaims.karpenter.sh meta.helm.sh/release-namespace=kube-system --overwrite
kubectl annotate crd nodeclaims.karpenter.sh meta.helm.sh/release-name=karpenter --overwrite
kubectl label crd nodeclaims.karpenter.sh app.kubernetes.io/managed-by=Helm --overwrite
# kubectl rollout restart deployment karpenter -n kube-system
```

### Uninstall aws-efs-csi-driver
```bash
helm uninstall aws-efs-csi-driver -n kube-system
```

# Terraform Apply
```bash
terraform apply
```