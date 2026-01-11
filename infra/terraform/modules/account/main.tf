resource "google_service_account" "this" {
  account_id   = "${var.service_name}-run-app-executor"
  display_name = "${var.service_name}-run-app-executor"
}

resource "google_project_iam_member" "this" {
  for_each = toset(var.run_app_executor)
  project  = var.project
  role     = each.key
  member   = google_service_account.this.member
}

# Allow developers to impersonate this service account for local development
# This enables signed URL generation without downloading service account keys
resource "google_service_account_iam_member" "developer_token_creator" {
  for_each           = toset(var.developer_emails)
  service_account_id = google_service_account.this.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "user:${each.value}"
}
