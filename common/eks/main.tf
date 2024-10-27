data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = var.required_eks_cluster_name
}

locals {
  template_path        = "../common/eks/user_data/join_cluster.tpl"
  generated_path       = "../common/eks/user_data/${var.required_eks_cluster_name}-join-cluster.sh"
  linux_device_storage = ["/dev/sdb", "/dev/sdc", "/dev/sdd", "/dev/sde", "/dev/sdf", "/dev/sdg", "/dev/sdh", "/dev/sdi", "/dev/sdj", "/dev/sdk", "/dev/sdl", "/dev/sdmn", "/dev/sdn", "/dev/sdo", "/dev/sdp", "/dev/sdq"]
}

resource "aws_eks_cluster" "eks_cluster" {
  name                      = var.required_eks_cluster_name
  role_arn                  = aws_iam_role.eks_cluster_role.arn
  enabled_cluster_log_types = try(var.eks_cluster_log_types, [])
  version                   = var.required_eks_version

  vpc_config {
    subnet_ids              = var.required_subnet_ids
    endpoint_private_access = try(var.private_cluster_enabled, false)
    endpoint_public_access  = try(var.public_cluster_enabled, false)
    public_access_cidrs     = try(var.public_access_cidrs, null)
    security_group_ids      = try(var.required_eks_security_group_ids, null)
  }

  kubernetes_network_config {
    service_ipv4_cidr = try(var.kubernetes_network_cidr, null)
    ip_family         = "ipv4"
  }

  dynamic "encryption_config" {
    for_each = try(var.cluster_encryption_enabled, false) == true ? [1] : []
    content {
      provider {
        key_arn = var.cluster_kms_arn
      }
      resources = ["secrets"]
    }
  }

  tags = var.cluster_tags
}


#### Read local file from folder user data
resource "local_file" "build_eks_worker_join_cluster_script" {
  content = templatefile(local.template_path, {
    cluster_name   = try(aws_eks_cluster.eks_cluster.id, null)
    cert_auth      = try(aws_eks_cluster.eks_cluster.certificate_authority.0.data, null)
    api_server_url = try(aws_eks_cluster.eks_cluster.endpoint, null)
    dns_cluster_ip = cidrhost(aws_eks_cluster.eks_cluster.kubernetes_network_config.0.service_ipv4_cidr, "10")
  })
  filename = try(local.generated_path, null)

  depends_on = [aws_eks_cluster.eks_cluster]
}

data "local_file" "get_eks_worker_join_cluster_script" {
  filename   = local.generated_path
  depends_on = [local_file.build_eks_worker_join_cluster_script]
}

data "tls_certificate" "eks_cluster" {
  url = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}


### Auto Scaling worker node
resource "aws_launch_template" "eks_worker_template" {
  count                  = try(var.customized_managed_nodegroup_enabled, false) == true ? 1 : 0
  name                   = var.required_launch_template_name
  description            = var.launch_template_description
  default_version        = var.launch_template_name_initial_verison
  update_default_version = var.launch_template_upgrade_version
  image_id               = var.required_launch_template_name_ami
  instance_type          = var.required_launch_template_name_instance_type
  dynamic "block_device_mappings" {
    for_each = try(var.launch_template_ebs_storages, null) == null ? [] : var.launch_template_ebs_storages
    content {
      device_name  = local.linux_device_storage[index(var.launch_template_ebs_storages, block_device_mappings.value)]
      virtual_name = block_device_mappings.value.virtual_name
      no_device    = null
      ebs {
        delete_on_termination = block_device_mappings.value.delete_on_termination
        encrypted             = block_device_mappings.value.encrypted
        kms_key_id            = var.launch_template_ebs_kms_key_id
        volume_type           = block_device_mappings.value.required_volume_type
        volume_size           = block_device_mappings.value.required_volume_size
      }
    }
  }
  vpc_security_group_ids = try(var.required_launch_template_vpc_security_group_ids, null) == null ? [aws_eks_cluster.eks_cluster.vpc_config.0.cluster_security_group_id] : concat([aws_eks_cluster.eks_cluster.vpc_config.0.cluster_security_group_id], flatten([for sg in var.required_launch_template_vpc_security_group_ids : [sg]]))
  user_data              = data.local_file.get_eks_worker_join_cluster_script.content_base64
  key_name               = var.key_name
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 2
  }
  tag_specifications {
    resource_type = "instance"
    tags          = try(var.launch_template_tags, {})
  }
  tags = try(var.launch_template_resource_tags, null)

  depends_on = [
    data.local_file.get_eks_worker_join_cluster_script
  ]
}


resource "aws_eks_node_group" "eks_manage_nodegroup" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.required_eks_nodegroup_name
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.required_eks_nodegroup_subnet_ids

  dynamic "launch_template" {
    for_each = try(var.customized_managed_nodegroup_enabled, false) == true ? [1] : []
    content {
      id      = aws_launch_template.eks_worker_template[0].id
      version = aws_launch_template.eks_worker_template[0].latest_version
    }
  }

  scaling_config {
    desired_size = try(var.required_eks_nodegroup_desired_size, 0)
    min_size     = try(var.required_eks_nodegroup_min_size, 0)
    max_size     = try(var.required_eks_nodegroup_max_size, 0)
  }

  dynamic "update_config" {
    for_each = (try(var.max_unavailable_worker_nodes_percent, null) != null || try(var.max_unavailable_num_of_worker_nodes, null) != null) ? [1] : []
    content {
      #(Optional) Desired max number of unavailable worker nodes during node group update.
      max_unavailable = try(var.max_unavailable_worker_nodes_percent, null) == null ? try(var.max_unavailable_num_of_worker_nodes, null) : null
      #(Optional) Desired max percentage of unavailable worker nodes during node group update
      max_unavailable_percentage = try(var.max_unavailable_num_of_worker_nodes, null) == null ? try(var.max_unavailable_worker_nodes_percent, null) : null
    }
  }

  dynamic "taint" {
    for_each = try(var.kubernetes_taint, null) == null ? [] : var.kubernetes_taint
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }


  force_update_version = try(var.force_update_version, false)
  labels               = try(var.kubernetes_labels, null) == null ? {} : var.kubernetes_labels
  release_version      = try(var.ami_release_version, null)

  version = try(var.kubernetes_version, null)
  tags    = var.eks_nodegroup_tags

  timeouts {
    create = "60m"
  }

  depends_on = [aws_eks_cluster.eks_cluster]
}

### EKS Addon
resource "aws_eks_addon" "eks_addon" {
  count                       = length(var.eks_add_ons)
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = var.eks_add_ons[count.index].required_addon_name
  addon_version               = try(var.eks_add_ons[count.index].version, null)
  service_account_role_arn    = try(var.eks_add_ons[count.index].service_account_role_arn, null)
  resolve_conflicts_on_update = try(var.eks_add_ons[count.index].resolve_conflicts_on_update, "OVERWRITE")

  tags = try(var.eks_add_ons[count.index].addon_tags, {})
  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}