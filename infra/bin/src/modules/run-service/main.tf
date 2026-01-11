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
      name  = "nginx-proxy"
      image = "${var.location}-docker.pkg.dev/${var.project}/${var.service_name}-app-repository-docker/nginx-proxy:latest"

      ports {
        name           = "http1"
        container_port = 8080
      }

      depends_on = ["app-frontend"]

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
          port = 8080
        }
      }
    }

    containers {
      name  = "app-frontend"
      image = "${var.location}-docker.pkg.dev/${var.project}/${var.service_name}-app-repository-docker/app-frontend:latest"

      env {
        name  = "PORT"
        value = "3000"
      }

      depends_on = ["app-backend"]

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
          port = 3000
        }
      }
    }

    containers {
      name  = "app-backend"
      image = "${var.location}-docker.pkg.dev/${var.project}/${var.service_name}-app-repository-docker/app-backend:latest"

      env {
        name  = "PORT"
        value = "8000"
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

resource "google_cloud_run_domain_mapping" "this" {
  name     = var.domain
  location = var.location
  metadata {
    namespace = var.project
  }
  spec {
    route_name = google_cloud_run_v2_service.this.name
  }
}
