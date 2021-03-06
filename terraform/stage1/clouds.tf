module "gcp" {
  source = "../modules/cloud-gcp"
  environment = var.environment
  regions = local.gcp_regions
  iap_support_email = var.iap_support_email
}

module "aws" {
  count = length(local.aws_regions) > 0 ? 1 : 0
  source = "../modules/cloud-aws"
  environment = var.environment
  regions = local.aws_regions
}
