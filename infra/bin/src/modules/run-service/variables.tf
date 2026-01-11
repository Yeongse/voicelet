variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "sa_email" {
  description = "run app executor's email"
  type        = string
}

variable "location" {
  description = "Region for Cloud Run"
  type        = string
  default     = "asia-northeast1"
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
}

variable "domain" {
  description = "Domain Name"
  type        = string
}
