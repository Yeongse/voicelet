variable "location" {
  description = "Region for Cloud Run"
  type        = string
  default     = "asia-northeast1"
}

variable "service_name" {
  description = "Service name prefix"
  type        = string
}
