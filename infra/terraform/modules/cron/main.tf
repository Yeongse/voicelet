# Cloud Scheduler job for deleting expired posts
resource "google_cloud_scheduler_job" "delete_expired_posts" {
  name        = "${var.service_name}-delete-expired-posts"
  description = "Deletes expired posts once a day"
  schedule    = "0 3 * * *" # Every day at 3:00 AM
  time_zone   = "Asia/Tokyo"
  region      = var.location

  retry_config {
    retry_count          = 3
    min_backoff_duration = "5s"
    max_backoff_duration = "60s"
  }

  http_target {
    uri         = "${var.cloud_run_url}/jobs/cleanup"
    http_method = "POST"

    oidc_token {
      service_account_email = var.sa_email
      audience              = var.cloud_run_url
    }
  }
}

