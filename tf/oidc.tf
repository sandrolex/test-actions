module "gcp-oidc" {
  source                     = "./modules/gcp-oidc"
  github_repository          = "sandrolex/test-actions"
  github_repository_branches = ["test-gcp"]
  project                    = local.project
  allow_write                = false
  allow_on_pull_requests     = false

  storage_bucket = "artifacts.${local.project}.appspot.com"
}


