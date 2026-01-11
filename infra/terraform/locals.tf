locals {
  project      = "voicelet"
  service_name = "voicelet"
  location     = "asia-northeast1"

  # ローカル開発でImpersonationを使う開発者のメールアドレス
  # 空の場合はサービスアカウントキーのダウンロードが必要
  developer_emails = [
    "yeongsekim@gmail.com",
  ]
}

locals {
  run_app_executor = [
    # Cloud SQL使用時
    # "roles/cloudsql.client",
    # "roles/cloudsql.instanceUser",
    "roles/secretmanager.secretAccessor",   # Secret参照用
    "roles/storage.objectAdmin",            # GCSオブジェクトの読み書き（署名付きURL生成含む）
    "roles/iam.serviceAccountTokenCreator", # 署名付きURL生成に必要（signBlob権限）
    "roles/monitoring.metricWriter",        # メトリクス送信
    "roles/run.invoker",                    # Cloud Scheduler から Cloud Run 呼び出し用
  ]
}
