resource "google_iam_workload_identity_pool" "pool" {
  workload_identity_pool_id = "gha-pool"
  display_name              = "GHA Pool"
  description               = "Pool for ${var.github_repository}"
  project                   = var.project

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_iam_workload_identity_pool_provider" "provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "gha-provider"
  display_name                       = "GHA Provider"
  description                        = "Provider for ${var.github_repository}"
  project                            = var.project
  attribute_mapping = {
    "google.subject" = "assertion.sub"
    # "attribute.repository" = "assertion.repository"
    # "assertion.ref" = "refs/heads/main"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_service_account" "github_actions_read" {
  // We increase probability of collisions here, but there's requirement on length as well as starting on a letter, which is not a guarantee for md5
  account_id   = "r${substr(local.role_name_md5, 0, 29)}"
  display_name = "gha oidc READ ${var.github_repository}"
  project      = var.project
}

resource "google_service_account" "github_actions_write" {
  // We increase probability of collisions here, but there's requirement on length as well as starting on a letter, which is not a guarantee for md5
  account_id   = "w${substr(local.role_name_md5, 0, 29)}"
  display_name = "gha oidc WRITE ${var.github_repository}"
  project      = var.project
}

resource "google_storage_bucket_iam_member" "gcr_read" {
  bucket = var.storage_bucket
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.github_actions_read.email}"
}

resource "google_storage_bucket_iam_member" "gcr_write" {
  bucket = var.storage_bucket
  role   = "roles/storage.legacyBucketWriter"
  member = "serviceAccount:${google_service_account.github_actions_write.email}"
}


resource "google_service_account_iam_member" "wif-sa_read" {
  service_account_id = google_service_account.github_actions_read.id
  role               = "roles/iam.workloadIdentityUser"
  #   member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.repository/${var.github_repository}"
  member = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/subject/repo:${var.github_repository}:ref:refs/heads/test-gcp"
}


resource "google_service_account_iam_member" "wif-sa_read-pr" {
  service_account_id = google_service_account.github_actions_read.id
  role               = "roles/iam.workloadIdentityUser"
  #   member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.repository/${var.github_repository}"
  member = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/subject/repo:${var.github_repository}:pull_request"
}

resource "google_service_account_iam_member" "wif-sa_write-pr" {
  service_account_id = google_service_account.github_actions_write.id
  role               = "roles/iam.workloadIdentityUser"
  #   member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.repository/${var.github_repository}"
  member = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/subject/repo:${var.github_repository}:pull_request"
}


