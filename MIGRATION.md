# AWS EKS Blurpeint Migration v4 to v5
The terraform state needs to be migrated to avoid deleting and re-creating resources.

## Initial Changes
```bash
  # module.eks.data.tls_certificate.this[0] will be read during apply
  # module.eks.aws_cloudwatch_log_group.this[0] will be created
  # module.eks.aws_ec2_tag.cluster_primary_security_group["Blueprint"] will be created
  # module.eks.aws_ec2_tag.cluster_primary_security_group["GithubRepo"] will be created
  # module.eks.aws_eks_cluster.this[0] will be created
  # module.eks.aws_iam_openid_connect_provider.oidc_provider[0] will be created
  # module.eks.aws_iam_policy.cluster_encryption[0] will be created
  # module.eks.aws_iam_role.this[0] will be created
  # module.eks.aws_iam_role_policy_attachment.additional["AmazonEBSCSIDriverPolicy"] will be created
  # module.eks.aws_iam_role_policy_attachment.additional["AmazonEC2ContainerRegistryReadOnly"] will be created
  # module.eks.aws_iam_role_policy_attachment.cluster_encryption[0] will be created
  # module.eks.aws_iam_role_policy_attachment.this["AmazonEKSClusterPolicy"] will be created
  # module.eks.aws_security_group.cluster[0] will be created
  # module.eks.aws_security_group.node[0] will be created
  # module.eks.aws_security_group_rule.cluster["ingress_nodes_443"] will be created
  # module.eks.aws_security_group_rule.cluster["ingress_nodes_karpenter_ports_tcp"] will be created
  # module.eks.aws_security_group_rule.node["egress_all"] will be created
  # module.eks.aws_security_group_rule.node["ingress_allow_alb_webhook_access_from_control_plane"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_10251_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_443"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_4443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_6443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_8443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_9443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_kubelet"] will be created
  # module.eks.aws_security_group_rule.node["ingress_nodes_ephemeral"] will be created
  # module.eks.aws_security_group_rule.node["ingress_nodes_karpenter_port"] will be created
  # module.eks.aws_security_group_rule.node["ingress_nodes_matrics_server_port"] will be created
  # module.eks.aws_security_group_rule.node["ingress_self_all"] will be created
  # module.eks.aws_security_group_rule.node["ingress_self_coredns_tcp"] will be created
  # module.eks.aws_security_group_rule.node["ingress_self_coredns_udp"] will be created
  # module.eks.time_sleep.this[0] will be created
  # module.eks_blueprints.kubernetes_config_map.aws_auth[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.aws_cloudformation_stack.usage_telemetry[0] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["aws-ebs-csi-driver"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["coredns"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["kube-proxy"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["kubecost_kubecost"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["vpc-cni"] will be created
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
terraform import 'module.eks.aws_cloudwatch_log_group.this[0]' '/aws/eks/k8s-time-based-scaling/cluster'
# If the CloudWatch Log Group fails to import, disable logging on the cluster and delete existing CloudWatch Log Group

[Addons](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/docs/v4-to-v5/addons.md#upgrade-migrations)

## Final Changes
```bash
  # module.eks.aws_eks_cluster.this[0] has changed
  # module.eks.module.kms.aws_kms_key.this[0] has changed
  # module.eks.data.tls_certificate.this[0] will be read during apply
  # module.eks.aws_cloudwatch_log_group.this[0] will be created
  # module.eks.aws_ec2_tag.cluster_primary_security_group["GithubRepo"] will be updated in-place
  # module.eks.aws_eks_cluster.this[0] will be updated in-place
  # module.eks.aws_iam_openid_connect_provider.oidc_provider[0] will be updated in-place
  # module.eks.aws_iam_policy.cluster_encryption[0] will be created
  # module.eks.aws_iam_role.this[0] will be updated in-place
  # module.eks.aws_iam_role_policy_attachment.additional["AmazonEBSCSIDriverPolicy"] will be created
  # module.eks.aws_iam_role_policy_attachment.additional["AmazonEC2ContainerRegistryReadOnly"] will be created
  # module.eks.aws_iam_role_policy_attachment.cluster_encryption[0] will be created
  # module.eks.aws_iam_role_policy_attachment.this["AmazonEKSVPCResourceController"] will be destroyed
  # module.eks.aws_security_group.cluster[0] will be updated in-place
  # module.eks.aws_security_group.node[0] will be updated in-place
  # module.eks.aws_security_group_rule.cluster["ingress_nodes_karpenter_ports_tcp"] will be created
  # module.eks.aws_security_group_rule.node["egress_all"] will be created
  # module.eks.aws_security_group_rule.node["ingress_allow_alb_webhook_access_from_control_plane"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_10251_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_4443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_6443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_8443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_cluster_9443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_nodes_ephemeral"] will be created
  # module.eks.aws_security_group_rule.node["ingress_nodes_karpenter_port"] will be created
  # module.eks.aws_security_group_rule.node["ingress_nodes_matrics_server_port"] will be created
  # module.eks.aws_security_group_rule.node["ingress_self_all"] will be created
  # module.eks.aws_security_group_rule.node["ingress_self_coredns_udp"] will be updated in-place
  # module.eks.time_sleep.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.aws_cloudformation_stack.usage_telemetry[0] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["aws-ebs-csi-driver"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["coredns"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["kube-proxy"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["kubecost_kubecost"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["vpc-cni"] will be created
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
  # module.eks_blueprints_kubernetes_addons.module.aws_coredns[0].aws_eks_addon.coredns[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_coredns[0].time_sleep.this will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_ebs_csi_driver[0].aws_eks_addon.aws_ebs_csi_driver[0] will be destroyed
  # module.eks_blueprints_kubernetes_addons.module.aws_ebs_csi_driver[0].aws_iam_policy.aws_ebs_csi_driver[0] will be destroyed
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

```bash
  # module.eks.module.eks_managed_node_group["managed_ondemand"].aws_eks_node_group.this[0] has changed
  # module.eks.data.tls_certificate.this[0] will be read during apply
  # module.eks.aws_cloudwatch_log_group.this[0] will be created
  # module.eks.aws_ec2_tag.cluster_primary_security_group["GithubRepo"] will be updated in-place
  # module.eks.aws_eks_cluster.this[0] will be updated in-place
  # module.eks.aws_iam_openid_connect_provider.oidc_provider[0] will be updated in-place
  # module.eks.aws_iam_role_policy_attachment.this["AmazonEKSVPCResourceController"] will be destroyed
  # module.eks.aws_security_group_rule.node["ingress_cluster_8443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_nodes_karpenter_port"] will be destroyed
  # module.eks.time_sleep.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.aws_cloudformation_stack.usage_telemetry[0] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["aws-ebs-csi-driver"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["coredns"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["kube-proxy"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["kubecost_kubecost"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["vpc-cni"] will be created
  # module.eks_blueprints_kubernetes_addons.time_sleep.this will be created
  # module.eks.module.eks_managed_node_group["managed_ondemand"].aws_eks_node_group.this[0] must be replaced
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.aws_iam_role.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.aws_iam_role_policy_attachment.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.helm_release.this[0] will be created
  # module.eks.module.eks_managed_node_group["managed_ondemand"].module.user_data.null_resource.validate_cluster_service_cidr will be created
  ```

  ```bash
    # module.eks.data.tls_certificate.this[0] will be read during apply
  # module.eks.aws_cloudwatch_log_group.this[0] will be created
  # module.eks.aws_ec2_tag.cluster_primary_security_group["GithubRepo"] will be updated in-place
  # module.eks.aws_eks_cluster.this[0] will be updated in-place
  # module.eks.aws_iam_openid_connect_provider.oidc_provider[0] will be updated in-place
  # module.eks.aws_iam_role_policy_attachment.this["AmazonEKSVPCResourceController"] will be destroyed
  # module.eks.aws_security_group_rule.cluster["ingress_nodes_karpenter_ports_tcp"] will be destroyed
  # module.eks.aws_security_group_rule.node["ingress_cluster_8443_webhook"] will be created
  # module.eks.aws_security_group_rule.node["ingress_nodes_karpenter_port"] will be destroyed
  # module.eks.time_sleep.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.aws_cloudformation_stack.usage_telemetry[0] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["aws-ebs-csi-driver"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["coredns"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["kube-proxy"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["kubecost_kubecost"] will be created
  # module.eks_blueprints_kubernetes_addons.aws_eks_addon.this["vpc-cni"] will be created
  # module.eks_blueprints_kubernetes_addons.time_sleep.this will be created
  # module.eks.module.eks_managed_node_group["managed_ondemand"].aws_eks_node_group.this[0] must be replaced
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.aws_iam_role.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.aws_iam_role_policy_attachment.this[0] will be created
  # module.eks_blueprints_kubernetes_addons.module.aws_efs_csi_driver.helm_release.this[0] will be created
  # module.eks.module.eks_managed_node_group["managed_ondemand"].module.user_data.null_resource.validate_cluster_service_cidr will be created
```