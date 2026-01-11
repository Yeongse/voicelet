variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "Region for Cloud Storage"
  type        = string
  default     = "asia-northeast1"
}

variable "service_name" {
  description = "Service name prefix"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

