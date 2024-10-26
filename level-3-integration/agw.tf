module "dump_agw" {
  source   = "../common/dump_agw"
  api_name = "poc-dev-api-idp-lp"


  # Stage
  stage_name = "dev"
}