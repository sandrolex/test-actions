resource "google_iam_workload_identity_pool" "pool" {
  workload_identity_pool_id = "new-pool-tf"
  display_name              = "Pool Created from TF"
  description               = "Pool Created form TF desc"
  project                   = local.project

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_iam_workload_identity_pool_provider" "provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "new-pool-tf"
  display_name                       = "new-pool-tf"
  description                        = "GitHub Actions OIDC identity pool provider "
  project                            = local.project
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  lifecycle {
    prevent_destroy = true
  }
}



resource "google_service_account" "github_actions" {
  // We increase probability of collisions here, but there's requirement on length as well as starting on a letter, which is not a guarantee for md5
  account_id   = "gha-oidc"
  display_name = "gha oidc"
  project      = local.project
}

resource "google_project_iam_member" "storage_admin" {
  role    = "roles/storage.objectViewer"
  project = local.project
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# resource "google_storage_bucket_iam_member" "gcr_read" {
#   bucket = var.storage_bucket
#   role   = "roles/storage.objectViewer"
#   member = "serviceAccount:${google_service_account.github_actions.email}"
# }

# resource "google_storage_bucket_iam_member" "gcr_write" {
#   bucket = var.storage_bucket
#   role   = "roles/storage.legacyBucketWriter"
#   member = "serviceAccount:${google_service_account.github_actions.email}"
# }
