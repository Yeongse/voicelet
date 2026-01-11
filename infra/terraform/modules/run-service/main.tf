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

      # コンテナがリッスンするポート（PORT環境変数に自動設定される）
      ports {
        container_port = 3002
      }

      # ============================================
      # 自動設定される環境変数（Terraform管理）
      # NOTE: PORT は ports.container_port の値が自動設定される
      # ============================================
      env {
        name  = "GCS_BUCKET_NAME"
        value = var.gcs_bucket_name
      }

      env {
        name  = "GCS_AVATAR_BUCKET_NAME"
        value = var.gcs_avatar_bucket_name
      }

      # ============================================
      # 手動設定が必要な環境変数（Secret Manager経由）
      # デプロイ前に gcloud secrets versions add で値を設定すること
      # 詳細は infra/README.md の「3.2. Secret Manager の設定」を参照
      # ============================================

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

      # Database URL from Secret Manager
      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = "${var.service_name}-database-url"
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
          port = 3002
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

