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

module "run-service" {
  source       = "./modules/run-service"
  project      = local.project
  location     = local.location
  service_name = local.service_name
  domain       = local.domain_name
  sa_email     = module.account.run_app_executor_email
}

module "dns" {
  source           = "./modules/dns/"
  service_name     = local.service_name
  domain           = local.domain_name
  cert_txt_record  = local.certification_txt
  is_apex_domain   = true
  dns_records_A    = module.run-service.dns_records_A
  dns_records_AAAA = module.run-service.dns_records_AAAA
  dns_record_WWW   = module.run-service.dns_record_WWW
}
