# Secret Manager secrets for Voicelet
# Note: Secret values should be set manually via GCP Console or gcloud CLI

resource "google_secret_manager_secret" "supabase_url" {
  secret_id = "${var.service_name}-supabase-url"

  replication {
    auto {}
  }

  labels = {
    app = var.service_name
  }
}

resource "google_secret_manager_secret" "supabase_service_key" {
  secret_id = "${var.service_name}-supabase-service-key"

  replication {
    auto {}
  }

  labels = {
    app = var.service_name
  }
}

resource "google_secret_manager_secret" "jwt_secret" {
  secret_id = "${var.service_name}-jwt-secret"

  replication {
    auto {}
  }

  labels = {
    app = var.service_name
  }
}

resource "google_secret_manager_secret" "database_url" {
  secret_id = "${var.service_name}-database-url"

  replication {
    auto {}
  }

  labels = {
    app = var.service_name
  }
}

# Grant the service account access to the secrets
resource "google_secret_manager_secret_iam_member" "supabase_url_access" {
  secret_id = google_secret_manager_secret.supabase_url.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.sa_email}"
}

resource "google_secret_manager_secret_iam_member" "supabase_service_key_access" {
  secret_id = google_secret_manager_secret.supabase_service_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.sa_email}"
}

resource "google_secret_manager_secret_iam_member" "jwt_secret_access" {
  secret_id = google_secret_manager_secret.jwt_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.sa_email}"
}

resource "google_secret_manager_secret_iam_member" "database_url_access" {
  secret_id = google_secret_manager_secret.database_url.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.sa_email}"
}

