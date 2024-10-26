common_tags = {
  "project_code" = "quypx-poc"
  "env"          = "uat"
}

eks = {
  quypx-poc-uat-eks-cluster-control-plane = {
    cluster_name                     = "quypx-poc-uat-eks-cluster-control-plane"
    cluster_log_types                = []
    kubernetes_version               = "1.30"
    subnet_ids                       = ["quypx-poc-uat-subnet-private-1a-app", "quypx-poc-uat-subnet-private-1b-app"]
    cluster_encryption_enabled       = false
    cluster_kms_arn                  = null
    private_cluster                  = true
    public_cluster                   = true
    public_cidrs                     = null
    security_group_ids               = ["quypx-poc-uat-sgrp-eksWorkerNode"] # Default sg
    kubernetes_network_cidr          = null
    cluster_tags                     = { "name" : "quypc-poc-uat-eks-cluster-control-plane" }

    customized_managed_nodegroup_enabled = true
    launch_template = {
      name               = "quypx-poc-uat-launch-template-ec2-workernode"
      description        = "EKS worker node launch template for karpenter"
      version            = null
      update_version     = true
      ami                = "ami-0b23e878db502a0bc" # Ubuntu for EKS v1.30 ami
      instance_type      = "t3.small"
      security_group_ids = ["quypx-poc-uat-sgrp-eksWorkerNode"]
      kms_key_id         = null
      key_name           = ""
      storages = [
        {
          virtual_name          = "quypx-poc-uat-eks-worker-node"
          delete_on_termination = true
          encrypted             = false
          required_volume_type  = "gp2"
          required_volume_size  = 20
        }
      ]
      tag_specifications = {
        Name = "quypx-poc-uat-ec2-workernode"
      }

      launch_template_resource_tags = {
        Name = "quypx-poc-uat-eks-worker-node"
      }
    }

    nodegroup = {
      name                                 = "quypx-poc-uat-eks-nodegroup"
      subnet_ids                           = ["quypx-poc-uat-subnet-private-1a-app", "quypx-poc-uat-subnet-private-1b-app"]
      desired_size                         = 1
      min_size                             = 1
      max_size                             = 1
      max_unavailable_worker_nodes_percent = null
      max_unavailable_num_of_worker_nodes  = 1
      force_update_version                 = false
      kubernetes_labels                    = null
      ami_release_version                  = null
      kubernetes_version                   = null

      tags = null
    }
  }
}

ecr = [
  {
    name          = "quypx-poc-uat-be-app"
    tag_immutable = false
    kms_enabled   = false
    kms_key_alias = null
    tags          = { "Name" : "quypx-poc-uat-be-app" }
  }
]