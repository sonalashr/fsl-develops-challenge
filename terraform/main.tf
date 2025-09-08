module "site" {
  source        = "./modules/static-site"
  project_name  = var.project_name
  unique_prefix = var.unique_prefix
  environment   = var.environment
}