provider "aws" {
  region = "ap-southeast-1"
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster["quypx-poc-uat-eks-cluster-control-plane"].cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster["quypx-poc-uat-eks-cluster-control-plane"].certificate_authority)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7.2"
    }
  }
  backend "s3" {}
}
