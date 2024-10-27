terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}

resource "helm_release" "karpenter" {
  name       = var.karpenter_name
  repository = var.karpenter_repository
  chart      = var.karpenter_chart
  version    = var.karpenter_version

  namespace        = var.karpenter_namespace
  create_namespace = var.create_namespace

  dynamic "set" {
    for_each = var.helm_settings
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}

resource "aws_ec2_tag" "subnets_tag" {
  for_each    = var.subnet_ids
  resource_id = each.value
  key         = var.tagging_key
  value       = var.cluster_name
}

resource "aws_ec2_tag" "security_groups_tag" {
  for_each    = var.security_group_ids
  resource_id = each.value
  key         = var.tagging_key
  value       = var.cluster_name
}

resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = <<YAML
      apiVersion: karpenter.sh/v1beta1
      kind: NodePool
      metadata:
        name: default
      spec:
        template:
          spec:
            requirements:
              - key: kubernetes.io/arch
                operator: In
                values: ["${var.k8s_arch}"]
              - key: kubernetes.io/os
                operator: In
                values: ["${var.k8s_os}"]
              - key: karpenter.sh/capacity-type
                operator: In
                values: ["${var.k8s_capacity_type}"]
              - key: karpenter.k8s.aws/instance-category
                operator: In
                values: ["${var.k8s_instance_category}"]
              - key: karpenter.k8s.aws/instance-family
                operator: In
                values: ["${var.k8s_instance_family}"]
              - key: karpenter.k8s.aws/instance-size
                operator: In
                values: ${jsonencode(var.k8s_instance_size)}
              - key: karpenter.k8s.aws/instance-generation
                operator: Gt
                values: ["${var.k8s_generation}"]
            nodeClassRef:
              apiVersion: karpenter.k8s.aws/v1beta1
              kind: EC2NodeClass
              name: default
        limits:
          cpu: ${var.karpenter_limit_cpu}
          memory: "${var.karpenter_limit_memory}"
        disruption:
          consolidationPolicy: WhenUnderutilized
          expireAfter: 720h # 30 * 24h = 720h
  YAML
  depends_on = [
    kubectl_manifest.ec2_node_class
  ]
}


resource "kubectl_manifest" "ec2_node_class" {
  yaml_body = <<YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2 
      role: "${var.node_class_role}"
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: "${var.cluster_name}"
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: "${var.cluster_name}"
      amiSelectorTerms:
        - id: "${var.amiSelector}"
  YAML
  depends_on = [
    helm_release.karpenter
  ]
}

