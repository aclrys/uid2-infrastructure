resource "google_iap_brand" "mission_control" {
  support_email     = var.iap_support_email
  application_title = "grafana-iap"
  project           = data.google_project.this.number
  depends_on        = [google_project_service.apis]
}

resource "google_iam_workload_identity_pool" "project" {
  provider                  = google-beta
  workload_identity_pool_id = local.project_id
  depends_on                = [google_project_service.apis]
}

resource "google_container_cluster" "mission_control" {
  for_each                 = toset(["mission-control"])
  name                     = "mission-control"
  location                 = var.regions[0]
  remove_default_node_pool = false
  initial_node_count       = 1
  ip_allocation_policy {
  }
  private_cluster_config {
    enable_private_nodes    = true
    master_ipv4_cidr_block  = cidrsubnet("10.124.0.0/20", 8, 0)
    enable_private_endpoint = false
  }
  release_channel {
    channel = "REGULAR"
  }
  node_config {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.compute.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  workload_identity_config {
    identity_namespace = "${local.project_id}.svc.id.goog"
  }
  cluster_autoscaling {
    enabled = true
    resource_limits {
      resource_type = "cpu"
      minimum       = 3
      maximum       = 30
    }
    resource_limits {
      resource_type = "memory"
      minimum       = 24
      maximum       = 240
    }
  }
  depends_on = [google_service_account_iam_binding.admin-account-iam, google_project_service.apis]
}

provider "helm" {
  kubernetes {
    host                   = google_container_cluster.mission_control["mission-control"].endpoint
    cluster_ca_certificate = base64decode(google_container_cluster.mission_control["mission-control"].master_auth.0.cluster_ca_certificate)
    token                  = data.google_client_config.provider.access_token
  }
}

module "gke_connect" {
  count          = 0
  source         = "../gke-connect-agent"
  cluster_id     = google_container_cluster.mission_control["mission-control"].id
  cluster_name   = google_container_cluster.mission_control["mission-control"].name
  project_number = data.google_project.this.number
  project_id     = local.project_id
  depends_on     = [google_project_service.apis]
}

resource "google_iap_web_iam_binding" "binding" {
  project = local.project_id
  role    = "roles/iap.httpsResourceAccessor"
  members = [
    "domain:prebid.org",
  ]
  depends_on = [google_project_service.apis]
}


module "mission_control_monitoring" {
  source                = "../prometheus-monitoring"
  project_id            = local.project_id
  domain_managed_zone   = var.domain_managed_zone
  location              = var.regions[0]
  cluster               = "mission-control"
  environment           = var.environment
  is_global             = true
  mission_control_ips   = google_compute_address.mission_control.*.address
  iap_brand             = google_iap_brand.mission_control.name
  thanos_query_backends = formatlist("thanos-${var.environment}-%s-%s.${trimsuffix(data.google_dns_managed_zone.uid2-0.dns_name, ".")}:443", keys(local.region_to_pet), values(local.region_to_pet))
}
