output "bucket_name" {
  description = "The name of the audio storage bucket"
  value       = google_storage_bucket.audio.name
}

output "bucket_url" {
  description = "The URL of the audio storage bucket"
  value       = google_storage_bucket.audio.url
}

output "bucket_self_link" {
  description = "The self link of the audio storage bucket"
  value       = google_storage_bucket.audio.self_link
}

output "avatar_bucket_name" {
  description = "The name of the avatar storage bucket"
  value       = google_storage_bucket.avatar.name
}

output "avatar_bucket_url" {
  description = "The URL of the avatar storage bucket"
  value       = google_storage_bucket.avatar.url
}

output "avatar_bucket_self_link" {
  description = "The self link of the avatar storage bucket"
  value       = google_storage_bucket.avatar.self_link
}

