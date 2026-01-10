# Audio files storage bucket for Voicelet
resource "google_storage_bucket" "audio" {
  name     = "${var.service_name}-audio-${var.project}"
  location = var.location

  # Uniform bucket-level access (recommended for security)
  uniform_bucket_level_access = true

  # Prevent public access
  public_access_prevention = "enforced"

  # Storage class
  storage_class = "STANDARD"

  # Lifecycle rule: delete files after 25 hours (余裕を持って24時間+1時間)
  lifecycle_rule {
    condition {
      age = 2 # days (GCSのageは日単位、最小1日。25時間は2日目に削除)
    }
    action {
      type = "Delete"
    }
  }

  # CORS configuration for signed URL uploads from mobile
  cors {
    origin          = ["*"]
    method          = ["GET", "PUT", "HEAD"]
    response_header = ["Content-Type", "Content-Length"]
    max_age_seconds = 3600
  }

  # Versioning disabled (files are ephemeral)
  versioning {
    enabled = false
  }

  # Force destroy for easier cleanup in dev
  force_destroy = true

  labels = {
    name        = "${var.service_name}-audio"
    environment = var.environment
  }
}

# Grant the backend service account permission to manage objects
# This allows generating signed URLs for upload/download
resource "google_storage_bucket_iam_member" "backend_object_admin" {
  bucket = google_storage_bucket.audio.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.sa_email}"
}

# Grant the service account permission to sign blobs (required for signed URLs)
# The service account needs to be able to sign URLs on its own behalf
resource "google_service_account_iam_member" "token_creator" {
  service_account_id = "projects/${var.project}/serviceAccounts/${var.sa_email}"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${var.sa_email}"
}

