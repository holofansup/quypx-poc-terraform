variable "cluster_name" {
  type = string
}

variable "subnet_ids" {

}

variable "tagging_key" {
  description = "karpenter tagging key"
  default     = "karpenter.sh/discovery"
}

variable "security_group_ids" {

}
variable "karpenter_version" {
  type    = string
  default = "0.5.3"
}

variable "karpenter_name" {
  type = string
}

variable "karpenter_repository" {
  type = string
}
variable "create_namespace" {
  type    = bool
  default = true
}
variable "karpenter_chart" {
  type = string
}

variable "karpenter_namespace" {
  type = string
}

variable "helm_settings" {
  type = list(object({
    name  = string
    value = string
  }))
}

variable "k8s_arch" {
  
}

variable "k8s_os" {
  
}

variable "k8s_capacity_type" {
  
}

variable "k8s_instance_category" {
  
}

variable "k8s_instance_family" {
  
}

variable "k8s_instance_size" {
  
}

variable "k8s_generation" {
  
}

variable "karpenter_limit_cpu" {
  
}

variable "karpenter_limit_memory" {
  
}

variable "node_class_role" {
  
}

variable "amiSelector" {
  
}
