variable "service_name" {
  description = "Service name prefix"
  type        = string
}

variable "location" {
  description = "Region for Cloud Scheduler"
  type        = string
  default     = "asia-northeast1"
}

variable "cloud_run_url" {
  description = "Cloud Run service URL"
  type        = string
}

variable "sa_email" {
  description = "Service account email for invoking Cloud Run"
  type        = string
}

