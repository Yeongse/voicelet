variable "service_name" {
  description = "Cloud Run service name"
  type        = string
}

variable "domain" {
  description = "Domain Name"
  type        = string
}

variable "is_apex_domain" {
  description = "Whether this is an apex domain (true) or subdomain (false)"
  type        = bool
  default     = true
}

variable "cert_txt_record" {
  description = "txt record for certification"
  type        = string
}

variable "dns_records_A" {
  description = "A records from Cloud Run domain mapping"
  type        = list(string)
  default     = []
}

variable "dns_records_AAAA" {
  description = "AAAA records from Cloud Run domain mapping"
  type        = list(string)
  default     = []
}

variable "dns_record_WWW" {
  description = "CNAME records from Cloud Run domain mapping"
  type        = list(string)
  default     = []
}
