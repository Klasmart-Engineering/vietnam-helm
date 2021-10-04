variable "terraform_project" {}
variable "terraform_region"  {}

variable "node_type" {
  type    = string
  default = "n1-highcpu-4"
}

variable "new_relic_iam_role_email" {
  type        = string
  description = "Name for the IAM Role to deploy for New Relic GCP monitoring. If not set, the IAM role will not be created."
  default     = ""
}
