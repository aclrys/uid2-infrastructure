
resource "google_container_cluster" "mission_control" {
  for_each = toset(["mission-control"])
  name     = "mission-control"
  location = var.regions[0]
  remove_default_node_pool = false
  initial_node_count       = 1
  ip_allocation_policy {
  }
  private_cluster_config {
    enable_private_nodes = false
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
      minimum = 3
      maximum = 30
    }
    resource_limits {
      resource_type = "memory"
      minimum = 24
      maximum = 240
    }
  }
  depends_on = [ google_service_account_iam_binding.admin-account-iam ]
}