module "artifact-registry" {
  source       = "./modules/artifact-registry"
  location     = local.location
  service_name = local.service_name
}

module "account" {
  source           = "./modules/account"
  project          = local.project
  service_name     = local.service_name
  run_app_executor = local.run_app_executor
}

module "secrets" {
  source       = "./modules/secrets"
  service_name = local.service_name
  sa_email     = module.account.run_app_executor_email
}

module "storage" {
  source       = "./modules/storage"
  project      = local.project
  location     = local.location
  service_name = local.service_name
  sa_email     = module.account.run_app_executor_email
  environment  = "dev"
}

module "run-service" {
  source          = "./modules/run-service"
  project         = local.project
  location        = local.location
  service_name    = local.service_name
  sa_email        = module.account.run_app_executor_email
  gcs_bucket_name = module.storage.bucket_name

  depends_on = [module.secrets, module.storage]
}

module "cron" {
  source        = "./modules/cron"
  service_name  = local.service_name
  location      = local.location
  cloud_run_url = module.run-service.url
  sa_email      = module.account.run_app_executor_email
}
