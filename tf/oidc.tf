module "gcp-oidc" {
  source            = "./modules/gcp-oidc"
  github_repository = "sandrolex/test-actions"
  project           = local.project
  allow_write       = false
  storage_bucket    = "artifacts.${local.project}.appspot.com"
}
