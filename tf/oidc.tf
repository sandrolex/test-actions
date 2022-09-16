module "gcp-oidc" {
  source                     = "./modules/gcp-oidc"
  github_repository          = "sandrolex/test-actions"
  github_repository_branches = ["main", "test-gcp"]
  project                    = local.project
  allow_write                = true
  allow_on_pull_requests     = true

  storage_bucket = "artifacts.${local.project}.appspot.com"
}
