resource "google_artifact_registry_repository" "this" {
  repository_id          = "${var.service_name}-app-repository-docker"
  location               = var.location
  format                 = "DOCKER"
  mode                   = "STANDARD_REPOSITORY"
  cleanup_policy_dry_run = false

  cleanup_policies {
    id     = "deletion-policy"
    action = "DELETE"

    condition {
      tag_state  = "ANY"
      older_than = "7d"
    }
  }

  cleanup_policies {
    id     = "keep-policy"
    action = "KEEP"

    most_recent_versions {
      keep_count = 10
    }
  }

  labels = {
    name = "${var.service_name}-app-repository-docker"
  }
}
