variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "service_name" {
  description = "Service name prefix"
  type        = string
}

variable "run_app_executor" {
  description = "executor cloud run service"
  type        = list(string)
}

variable "developer_emails" {
  description = "List of developer email addresses who can impersonate the service account for local development"
  type        = list(string)
  default     = []
}
