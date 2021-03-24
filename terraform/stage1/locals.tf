locals {
  gcp_regions   = matchkeys(var.regions, var.regions, ["asia-east1", "asia-east2", "asia-northeast1", "asia-northeast2", "asia-northeast3", "asia-south1", "asia-southeast1", "asia-southeast2", "australia-southeast1", "europe-north1", "europe-west1", "europe-west2", "europe-west3", "europe-west4", "europe-west6", "northamerica-northeast1", "southamerica-east1", "us-central1", "us-east1", "us-east4", "us-west1", "us-west2", "us-west3", "us-west4"])
  aws_regions   = matchkeys(var.regions, var.regions, ["eu-north-1", "ap-south-1", "eu-west-3", "eu-west-2", "eu-west-1", "ap-northeast-3", "ap-northeast-2", "ap-northeast-1", "sa-east-1", "ca-central-1", "ap-southeast-1", "ap-southeast-2", "eu-central-1", "us-east-1", "us-east-2", "us-west-1", "us-west-2"])
  azure_regions = matchkeys(var.regions, var.regions, ["Brazil South", "Canada Central", "Canada East", "Central India", "Central US", "East Asia", "East US", "East US 2", "Germany Central", "Germany Northeast", "Japan East", "Japan West", "Korea Central", "Korea South", "North Central US", "North Europe", "South Central US", "South East Asia", "South India", "UK South", "UK West", "West Central US", "West Europe", "West India", "West US", "West US 2"])
}