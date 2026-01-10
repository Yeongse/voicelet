output "supabase_url_secret_id" {
  description = "Secret ID for Supabase URL"
  value       = google_secret_manager_secret.supabase_url.secret_id
}

output "supabase_service_key_secret_id" {
  description = "Secret ID for Supabase Service Key"
  value       = google_secret_manager_secret.supabase_service_key.secret_id
}

output "jwt_secret_secret_id" {
  description = "Secret ID for JWT Secret"
  value       = google_secret_manager_secret.jwt_secret.secret_id
}

