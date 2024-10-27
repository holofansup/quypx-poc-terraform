common_tags = {
  "project_code" = "quypx-poc"
  "env"          = "uat"
}

eks = {
  quypx-poc-uat-eks-cluster-control-plane = {
    cluster_name               = "quypx-poc-uat-eks-cluster-control-plane"
    cluster_log_types          = []
    kubernetes_version         = "1.30"
    subnet_ids                 = ["quypx-poc-uat-subnet-private-1a-app", "quypx-poc-uat-subnet-private-1b-app"]
    cluster_encryption_enabled = false
    cluster_kms_arn            = null
    private_cluster            = true
    public_cluster             = true
    public_cidrs               = null
    security_group_ids         = ["quypx-poc-uat-sgrp-eksWorkerNode"] # Default sg
    kubernetes_network_cidr    = null
    cluster_tags               = { "name" : "quypc-poc-uat-eks-cluster-control-plane" }

    eks_addons = [
      {
        required_addon_name         = "vpc-cni"
        version                     = "v1.18.1-eksbuild.3"
        resolve_conflicts_on_update = "OVERWRITE"
        addon_tags                  = { "name" : "quypc-poc-uat-eks-addon-vpc-cni" }
        service_account_role_arn    = null
      },
      {
        required_addon_name         = "coredns"
        version                     = "v1.11.1-eksbuild.8"
        resolve_conflicts_on_update = "OVERWRITE"
        addon_tags                  = { "name" : "quypc-poc-uat-eks-addon-coredns" }
        service_account_role_arn    = null
      },
      {
        required_addon_name         = "kube-proxy"
        version                     = "v1.30.0-eksbuild.3"
        resolve_conflicts_on_update = "OVERWRITE"
        addon_tags                  = { "name" : "quypc-poc-uat-eks-addon-kube-proxy" }
        service_account_role_arn    = null
      },
      {
        required_addon_name         = "aws-ebs-csi-driver"
        version                     = "v1.36.0-eksbuild.1"
        resolve_conflicts_on_update = "OVERWRITE"
        addon_tags                  = { "name" : "quypc-poc-uat-eks-addon-aws-ebs-csi-driver" }
        service_account_role_arn    = null
      }
    ]

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

      kubernetes_taint = [
        {
          key    = "dedicated"
          value  = "karpenter"
          effect = "NO_EXECUTE"
        }
      ]
      kubernetes_labels = {
        "karpenter-nodegroup" = "quypx-poc-uat-eks-nodegroup"
      }

      tags = null
    }

    # Install Karpenter
    karpenter = {
      name             = "karpenter"
      repository       = "oci://public.ecr.aws/karpenter"
      chart            = "karpenter"
      version          = "0.35.0"
      create_namespace = true
      namespace        = "karpenter"
      tagging_key      = "karpenter.sh/discovery"
      subnet_ids = {
        "subnet1" = "quypx-poc-uat-subnet-private-1a-app"
        "subnet2" = "quypx-poc-uat-subnet-private-1b-app"
      }
      security_group_ids = {
        "sg1" = "quypx-poc-uat-sgrp-eksWorkerNode"
      }
      helm_settings = [
        {
          name  = "settings.clusterName"
          value = "quypx-poc-uat-eks-cluster-control-plane"
        },
        {
          name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
          value = "arn:aws:iam::851725269187:role/quypx-poc-uat-karpenter-controller-iamrole"
        },
        {
          name  = "replicas"
          value = "1"
        },
        {
          name  = "controller.resources.requests.cpu"
          value = "1"
        },
        {
          name  = "controller.resources.requests.memory"
          value = "1Gi"
        },
        {
          name  = "controller.resources.limits.cpu"
          value = "1"
        },
        {
          name  = "controller.resources.limits.memory"
          value = "1Gi"
        },
        {
          name  = "tolerations[0].key"
          value = "dedicated"
        },
        {
          name  = "tolerations[0].value"
          value = "karpenter"
        },
        {
          name  = "tolerations[0].operator"
          value = "Equal"
        },
        {
          name  = "tolerations[0].effect"
          value = "NoExecute"
        },
        {
          name  = "controller.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].nodeSelectorTerms.matchExpressions[0].key"
          value = "karpenter.sh/nodepool"
        },
        {
          name  = "controller.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].nodeSelectorTerms.matchExpressions[0].operator"
          value = "DoesNotExist"
        },
        {
          name  = "controller.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].nodeSelectorTerms.matchExpressions[1].key"
          value = "karpenter-nodegroup"
        },
        {
          name  = "controller.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].nodeSelectorTerms.matchExpressions[1].operator"
          value = "In"
        },
        {
          name  = "controller.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].nodeSelectorTerms.matchExpressions[1].values"
          value = "quypx-poc-uat-eks-nodegroup"
        },
        {
          name  = "controller.affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].topologyKey"
          value = "kubernetes.io/hostname"
        },
      ]

      ### Karpenter NodePool && Ec2Nodeclass configurations
      k8s_arch               = "amd64"
      k8s_os                 = "linux"
      k8s_capacity_type      = "on-demand"
      k8s_instance_category  = "t"
      k8s_instance_family    = "t3"
      k8s_instance_size      = ["small", "medium", "large"]
      k8s_generation         = "2"
      karpenter_limit_cpu    = "20"
      karpenter_limit_memory = "20Gi"
      node_class_role        = "quypx-poc-uat-eks-nodegroup-iamrole"
      amiSelector            = "ami-0b23e878db502a0bc" # Ubuntu for EKS v1.30 ami
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