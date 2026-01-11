locals {
  project           = "<project_id>"
  domain_name       = "<domain_name>"
  service_name      = "<service_name>" # 任意のサービス名
  location          = "asia-northeast1"
  certification_txt = "google-site-verification=xxx..."
}

locals {
  run_app_executor = [
    # Cloud SQL使用時
    # "roles/cloudsql.client",
    # "roles/cloudsql.instanceUser",
    "roles/secretmanager.secretAccessor", # Secret参照用
    "roles/storage.objectViewer",         # 必要に応じて(参照のみ)
    "roles/storage.objectCreator",        # 必要に応じて(作成のみ)
    "roles/monitoring.metricWriter",      # メトリクス送信
  ]
}
