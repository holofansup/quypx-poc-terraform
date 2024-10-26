# variable "required_eks_nodegroup_name" {
#   type    = string
#   default = null
# }

variable "required_eks_cluster_name" {
  type    = string
  default = null
}

variable "eks_cluster_log_types" {
  type    = list(string)
  default = null
}

variable "required_eks_version" {
  type    = string
  default = null
}

variable "required_subnet_ids" {
  type    = list(string)
  default = null
}

variable "private_cluster_enabled" {
  type    = bool
  default = false
}

variable "public_cluster_enabled" {
  type    = bool
  default = false
}

variable "public_access_cidrs" {
  type    = list(string)
  default = null
}
variable "required_eks_security_group_ids" {
  type    = list(string)
  default = null
}
variable "kubernetes_network_cidr" {
  type    = string
  default = null
}

variable "cluster_encryption_enabled" {
  type    = bool
  default = true
}

variable "cluster_kms_arn" {
  type    = string
  default = null
}

variable "cluster_tags" {
  type    = map(string)
  default = {}
}

### ADD On
variable "eks_add_ons" {
  type = list(object({
    required_addon_name      = string
    version                  = string
    resolve_conflicts        = string
    service_account_role_arn = string
    addon_tags               = map(string)
  }))
  default = [
    {
      required_addon_name      = null
      version                  = null
      resolve_conflicts        = null
      service_account_role_arn = null
      addon_tags               = null
    }
  ]
}


### Auto Scaling worker node
variable "customized_managed_nodegroup_enabled" {
  type    = bool
  default = false
}
variable "required_launch_template_name" {
  type    = string
  default = null
}
variable "launch_template_description" {
  type    = string
  default = null
}
variable "launch_template_name_initial_verison" {
  type    = number
  default = null
}
variable "launch_template_upgrade_version" {
  type    = bool
  default = null
}
variable "required_launch_template_name_ami" {
  type    = string
  default = null
}
variable "required_launch_template_name_instance_type" {
  type    = string
  default = null
}
variable "launch_template_ebs_storages" {
  type = list(object({
    virtual_name          = string
    delete_on_termination = bool
    encrypted             = bool
    required_volume_type  = string
    required_volume_size  = number
  }))
  default = [
    {
      virtual_name          = null
      delete_on_termination = null
      encrypted             = null
      required_volume_type  = null
      required_volume_size  = null
    }
  ]
}

variable "key_name" {
  type    = string
  default = null
}

variable "launch_template_ebs_kms_key_id" {
  type    = string
  default = null
}

variable "required_launch_template_vpc_security_group_ids" {
  type    = list(string)
  default = null
}

variable "launch_template_tags" {
  type    = map(string)
  default = null
}

variable "launch_template_resource_tags" {
  type    = map(string)
  default = null
}

## EKS Node manager
variable "required_eks_nodegroup_name" {
  type    = string
  default = null
}
variable "required_eks_nodegroup_subnet_ids" {
  type    = list(string)
  default = null
}
variable "required_eks_nodegroup_desired_size" {
  type    = number
  default = null
}
variable "required_eks_nodegroup_min_size" {
  type    = number
  default = null
}
variable "required_eks_nodegroup_max_size" {
  type    = number
  default = null
}
variable "max_unavailable_worker_nodes_percent" {
  type    = string
  default = null
}
variable "max_unavailable_num_of_worker_nodes" {
  type    = number
  default = null
}
variable "force_update_version" {
  type    = bool
  default = false
}
variable "kubernetes_labels" {
  type    = map(string)
  default = null
}
variable "ami_release_version" {
  type    = string
  default = null
}
variable "kubernetes_version" {
  type    = string
  default = null
}
variable "eks_nodegroup_tags" {
  type    = map(string)
  default = null
}
variable "kubernetes_taint" {
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = null
}