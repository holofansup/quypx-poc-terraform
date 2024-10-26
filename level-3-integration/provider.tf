terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.58"
    }
  }
  backend "s3" {
    bucket  = "poc-dev-s3-terraform-state"
    key     = "be/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }

}

provider "aws" {
  region                   = "ap-northeast-1"
  profile                  = "rikkei"
  shared_credentials_files = ["~/.aws/credentials"]
}