variable "github_repository" {
  type        = string
  description = "GitHub repository to which access will be provided."
}

# variable "github_repository_branch" {
#   type        = set(string)
#   description = "GitHub repository to which access will be provided."
# }

# variable "acr_registry" {
#   type        = string
#   description = "Name of the ACR Regitry"
# }

# variable "allow_on_pull_requests" {
#   type        = bool
#   default     = false
#   description = "Whether pull requests should have access to specified claims."
# }

variable "allow_write" {
  type    = bool
  default = false
}

variable "project" {
  type = string
}
