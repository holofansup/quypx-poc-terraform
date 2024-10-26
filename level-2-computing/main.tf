data "terraform_remote_state" "networking" {
  backend   = "s3"
  config = {
    bucket  = "quypx-poc-terraform-state"
    key     = "level-1-networking/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

locals {
  subnet_ids         = data.terraform_remote_state.networking.outputs.subnet_ids
  security_group_ids = data.terraform_remote_state.networking.outputs.security_group_ids

  common_tags = {
    project_code = "quypx-poc"
    env          = "uat"
  }
}