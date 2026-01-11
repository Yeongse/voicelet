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
