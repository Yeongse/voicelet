# ドメインマッピング機能で生成されるレコード情報を収集する
output "dns_records_A" {
  description = "generated A record"
  value       = [for rr in google_cloud_run_domain_mapping.this.status[0].resource_records : rr.rrdata if rr.type == "A"]
}

output "dns_records_AAAA" {
  description = "generated AAAA record"
  value       = [for rr in google_cloud_run_domain_mapping.this.status[0].resource_records : rr.rrdata if rr.type == "AAAA"]
}

output "dns_record_WWW" {
  description = "generated CNAME record"
  value       = [for rr in google_cloud_run_domain_mapping.this.status[0].resource_records : rr.rrdata if rr.type == "CNAME"]
}

output "url" {
  description = "url for access"
  value       = google_cloud_run_domain_mapping.this.name
}
