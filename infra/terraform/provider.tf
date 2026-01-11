terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.12"
    }
  }

  # backend はローカルに設定（必要に応じて別途設定）
}

# Configure the Google provider
provider "google" {
  project = local.project
  region  = "asia-northeast1"
}
