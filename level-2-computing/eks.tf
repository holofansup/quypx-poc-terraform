data "aws_eks_cluster_auth" "this" {
  name = module.eks_cluster["quypx-poc-uat-eks-cluster-control-plane"].cluster_name
}


data "aws_caller_identity" "current" {}

module "eks_cluster" {
  source = "../common/eks"

  for_each = try(var.eks, {}) # only have one eks cluster

  ## Simple EKS
  required_eks_cluster_name       = try(each.value.cluster_name, null)
  eks_cluster_log_types           = try(each.value.cluster_log_types, null)
  required_eks_version            = try(each.value.kubernetes_version, null)
  required_subnet_ids             = flatten([for id in each.value.subnet_ids : [try(local.subnet_ids[id], [])]])
  cluster_encryption_enabled      = try(each.value.cluster_encryption_enabled, null)
  cluster_kms_arn                 = try(each.value.cluster_kms_key_id, null)
  private_cluster_enabled         = try(each.value.private_cluster, null)
  public_cluster_enabled          = try(each.value.public_cluster, null)
  public_access_cidrs             = try(each.value.public_cidrs, null)
  required_eks_security_group_ids = flatten([for id in each.value.security_group_ids : [try(local.security_group_ids[id], [])]])
  kubernetes_network_cidr         = try(each.value.kubernetes_network_cidr, null)
  eks_add_ons                     = try(each.value.eks_addons, [])
  cluster_tags                    = merge(local.common_tags, try(each.value.cluster_tags, null))

  # Launch Template
  customized_managed_nodegroup_enabled        = each.value.customized_managed_nodegroup_enabled
  required_launch_template_name               = each.value.launch_template.name
  launch_template_description                 = each.value.launch_template.description
  launch_template_name_initial_verison        = each.value.launch_template.version
  launch_template_upgrade_version             = each.value.launch_template.update_version
  required_launch_template_name_ami           = each.value.launch_template.ami
  required_launch_template_name_instance_type = each.value.launch_template.instance_type
  launch_template_ebs_storages                = each.value.launch_template.storages
  # launch_template_ebs_kms_key_id                  = local.kms_key_arns[each.value.launch_template.kms_key_id]
  launch_template_ebs_kms_key_id                  = null
  required_launch_template_vpc_security_group_ids = flatten([for id in each.value.launch_template.security_group_ids : [try(local.security_group_ids[id], [])]])
  launch_template_tags                            = merge(var.common_tags, try(each.value.launch_template.tag_specifications, {}))
  launch_template_resource_tags                   = merge(var.common_tags, try(each.value.launch_template.tags, null))
  key_name                                        = try(each.value.launch_template.key_name, null)

  required_eks_nodegroup_name          = each.value.nodegroup.name
  required_eks_nodegroup_subnet_ids    = flatten([for id in each.value.nodegroup.subnet_ids : [try(local.subnet_ids[id], [])]])
  required_eks_nodegroup_desired_size  = each.value.nodegroup.desired_size
  required_eks_nodegroup_min_size      = each.value.nodegroup.min_size
  required_eks_nodegroup_max_size      = each.value.nodegroup.max_size
  max_unavailable_worker_nodes_percent = each.value.nodegroup.max_unavailable_worker_nodes_percent
  max_unavailable_num_of_worker_nodes  = each.value.nodegroup.max_unavailable_num_of_worker_nodes
  force_update_version                 = each.value.nodegroup.force_update_version
  kubernetes_labels                    = each.value.nodegroup.kubernetes_labels
  ami_release_version                  = each.value.nodegroup.ami_release_version

  kubernetes_version = each.value.nodegroup.kubernetes_version
  eks_nodegroup_tags = each.value.nodegroup.tags
}