output "name_servers" {
  value = module.dns.name_servers
}

# output "url" {
#   value = module.run-service.url
# }

output "audio_bucket_name" {
  description = "The name of the audio storage bucket (use as GCS_BUCKET_NAME env var)"
  value       = module.storage.bucket_name
}
