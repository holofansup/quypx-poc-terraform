module "karpenter" {
  source = "../common/eks/karpenter"

  for_each = try(var.eks, {})

  cluster_name = each.value.cluster_name

  karpenter_name       = each.value.karpenter.name
  karpenter_repository = each.value.karpenter.repository
  karpenter_chart      = each.value.karpenter.chart
  karpenter_version    = each.value.karpenter.version
  karpenter_namespace  = each.value.karpenter.namespace
  create_namespace     = each.value.karpenter.create_namespace
  tagging_key          = each.value.karpenter.tagging_key
  helm_settings        = each.value.karpenter.helm_settings

  subnet_ids = {
    for key, value in each.value.karpenter.subnet_ids :
    key => lookup(local.subnet_ids, value, null)
  }

  security_group_ids = {
    for key, value in each.value.karpenter.security_group_ids :
    key => lookup(local.security_group_ids, value, null)
  }

  k8s_arch               = each.value.karpenter.k8s_arch
  k8s_os                 = each.value.karpenter.k8s_os
  k8s_capacity_type      = each.value.karpenter.k8s_capacity_type
  k8s_instance_category  = each.value.karpenter.k8s_instance_category
  k8s_instance_family    = each.value.karpenter.k8s_instance_family
  k8s_instance_size      = each.value.karpenter.k8s_instance_size
  k8s_generation         = each.value.karpenter.k8s_generation
  karpenter_limit_cpu    = each.value.karpenter.karpenter_limit_cpu
  karpenter_limit_memory = each.value.karpenter.karpenter_limit_memory
  node_class_role        = each.value.karpenter.node_class_role
  amiSelector            = each.value.karpenter.amiSelector
}


### Karpenter Controller IAM Role

data "aws_eks_cluster" "eks_cluster" {
  name = module.eks_cluster["quypx-poc-uat-eks-cluster-control-plane"].cluster_name
}

data "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "karpenter_role" {
  name = "quypx-poc-uat-karpenter-controller-iamrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${data.aws_iam_openid_connect_provider.oidc.url}:sub" = "system:serviceaccount:karpenter:karpenter",
            "${data.aws_iam_openid_connect_provider.oidc.url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  depends_on = [ module.karpenter ]
}

resource "aws_iam_policy" "karpenter_policy" {
  name        = "quypx-poc-uat-karpenter-controller-iampolicy"
  description = "Policy for Karpenter"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Karpenter"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ec2:DescribeImages",
          "ec2:RunInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateTags",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:DescribeSpotPriceHistory",
          "pricing:GetProducts",
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
      },
      {
        Sid    = "ConditionalEC2Termination"
        Effect = "Allow"
        Action = "ec2:TerminateInstances"
        Resource = "*"
        Condition = {
          StringLike = {
            "ec2:ResourceTag/karpenter.sh/nodepool" = "*"
          }
        }
      },
      {
        Sid    = "PassNodeIAMRole"
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = "arn:aws:iam::851725269187:role/quypx-poc-uat-eks-nodegroup-iamrole"
      },
      {
        Sid    = "EKSClusterEndpointLookup"
        Effect = "Allow"
        Action = "eks:DescribeCluster"
        Resource = "arn:aws:eks:ap-southeast-1:851725269187:cluster/quypx-poc-uat-eks-cluster-control-plane"
      },
      {
        Sid    = "AllowScopedInstanceProfileCreationActions"
        Effect = "Allow"
        Action = [
          "iam:CreateInstanceProfile"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestTag/kubernetes.io/cluster/quypx-poc-uat-eks-cluster-control-plane" = "owned"
            "aws:RequestTag/topology.kubernetes.io/region" = "ap-southeast-1"
          }
          StringLike = {
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass" = "*"
          }
        }
      },
      {
        Sid    = "AllowScopedInstanceProfileTagActions"
        Effect = "Allow"
        Action = [
          "iam:TagInstanceProfile"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestTag/kubernetes.io/cluster/quypx-poc-uat-eks-cluster-control-plane" = "owned"
            "aws:RequestTag/topology.kubernetes.io/region" = "ap-southeast-1"
            "aws:ResourceTag/kubernetes.io/cluster/quypx-poc-uat-eks-cluster-control-plane" = "owned"
            "aws:ResourceTag/topology.kubernetes.io/region" = "ap-southeast-1"
          }
          StringLike = {
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass" = "*"
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass" = "*"
          }
        }
      },
      {
        Sid    = "AllowScopedInstanceProfileActions"
        Effect = "Allow"
        Action = [
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/kubernetes.io/cluster/quypx-poc-uat-eks-cluster-control-plane" = "owned"
            "aws:ResourceTag/topology.kubernetes.io/region" = "ap-southeast-1"
          }
          StringLike = {
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass" = "*"
          }
        }
      },
      {
        Sid    = "AllowInstanceProfileReadActions"
        Effect = "Allow"
        Action = "iam:GetInstanceProfile"
        Resource = "*"
      }
    ]
  })
  depends_on = [ aws_iam_role.karpenter_role ]
}

resource "aws_iam_role_policy_attachment" "karpenter_policy_attachment" {
  role       = aws_iam_role.karpenter_role.name
  policy_arn = aws_iam_policy.karpenter_policy.arn
}
