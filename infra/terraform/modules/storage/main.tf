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

  # Lifecycle rule: 2日後にARCHIVEストレージクラスに移行（コスト削減）
  # ARCHIVEは最も低コストだが、取り出し時に料金がかかる
  lifecycle_rule {
    condition {
      age = 2 # days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
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

# Profile avatar images storage bucket
resource "google_storage_bucket" "avatar" {
  name     = "${var.service_name}-avatar-${var.project}"
  location = var.location

  # Uniform bucket-level access (recommended for security)
  uniform_bucket_level_access = true

  # Prevent public access
  public_access_prevention = "enforced"

  # Storage class
  storage_class = "STANDARD"

  # No lifecycle rule - avatars are kept indefinitely

  # CORS configuration for signed URL uploads from mobile
  cors {
    origin          = ["*"]
    method          = ["GET", "PUT", "HEAD"]
    response_header = ["Content-Type", "Content-Length"]
    max_age_seconds = 3600
  }

  # Versioning disabled
  versioning {
    enabled = false
  }

  # Force destroy for easier cleanup in dev
  force_destroy = true

  labels = {
    name        = "${var.service_name}-avatar"
    environment = var.environment
  }
}

# Note: The backend service account has roles/storage.objectAdmin and 
# roles/iam.serviceAccountTokenCreator granted at the project level (in account module).
# This allows generating signed URLs for upload/download from any bucket in the project.

