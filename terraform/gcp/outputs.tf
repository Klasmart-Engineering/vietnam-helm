output "terraform_vpc" {
  value = module.vpc.vpc
}

output "terraform_subnet" {
  value = module.vpc.subnet
}

output "service_account_config_connector" {
  value = module.gke.service_account_config_connector
}
