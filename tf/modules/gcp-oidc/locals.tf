locals {
  role_name_md5 = md5(replace(var.github_repository, "/", "-"))
}
