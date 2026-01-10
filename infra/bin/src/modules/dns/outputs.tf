output "name_servers" {
  description = "Set these name servers at your domain registrar."
  value       = google_dns_managed_zone.this.name_servers
}
