variable "project"  {
  description = "GCP project ID to create the K8s cluster in"
  type        = string
  # No default - must be supplied
}

variable "region"  {
  description = "GCP region code to create the K8s cluster in"
  type        = string
  # No default - must be supplied
}

variable "vpc"  {
  description = "Self link for the GCP VPC to create the K8s cluster in"
  type        = string
  # No default - must be supplied (from the vpc module)
}

variable "subnet"  {
  description = "Self link for the GCP VPC subnetwork to create the K8s cluster in"
  type        = string
  # No default - must be supplied (from the vpc module)
}

variable "cluster_name" {
  description = "Name for the GKE cluster"
  type        = string
  default     = "kidsloop"
}

variable "maintenance_window" {
  description = "Time window specified for daily maintenance operations to START in RFC3339 format"
  type        = string
  default     = "05:00"
}

variable "node_count_initial" {
  type    = number
  default = 2
}

variable "node_count_min" {
  type    = number
  default = 1
}

variable "node_count_max" {
  type    = number
  default = 3
}

variable "node_type" {
  type    = string
  default = "n1-highcpu-4"
}

variable "node_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "node_disk_size" {
  type    = number
  default = 20
}

variable "service_account_name_cluster" {
  type    = string
  default = "kidsloop-cluster"
}

variable "service_account_name_config_connector" {
  type    = string
  default = "kidsloop-config-connector"
}

variable "node_poolsfu" {
  type    = string
  default = "poolsfu"
}