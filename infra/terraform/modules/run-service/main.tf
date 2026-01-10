resource "google_cloud_run_v2_service" "this" {
  name     = "${var.service_name}-run-service-app"
  location = var.location

  deletion_protection = false

  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = var.sa_email

    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"
    scaling {
      max_instance_count = 2
      min_instance_count = 0
    }


    containers {
      name  = "app-backend"
      image = "${var.location}-docker.pkg.dev/${var.project}/${var.service_name}-app-repository-docker/app-backend:latest"

      env {
        name  = "PORT"
        value = "8000"
      }

      env {
        name  = "GCS_BUCKET_NAME"
        value = var.gcs_bucket_name
      }

      # Supabase URL from Secret Manager
      env {
        name = "SUPABASE_URL"
        value_source {
          secret_key_ref {
            secret  = "${var.service_name}-supabase-url"
            version = "latest"
          }
        }
      }

      # Supabase Service Key from Secret Manager
      env {
        name = "SUPABASE_SERVICE_KEY"
        value_source {
          secret_key_ref {
            secret  = "${var.service_name}-supabase-service-key"
            version = "latest"
          }
        }
      }

      # JWT Secret from Secret Manager
      env {
        name = "JWT_SECRET"
        value_source {
          secret_key_ref {
            secret  = "${var.service_name}-jwt-secret"
            version = "latest"
          }
        }
      }

      resources {
        cpu_idle          = true
        startup_cpu_boost = false

        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }

      startup_probe {
        timeout_seconds   = 240
        period_seconds    = 240
        failure_threshold = 1
        tcp_socket {
          port = 8000
        }
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  name     = google_cloud_run_v2_service.this.name
  location = google_cloud_run_v2_service.this.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

