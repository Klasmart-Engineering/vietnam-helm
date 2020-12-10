variable "project"  {
  description = "GCP project ID to create the K8s cluster in"
  type        = string
}

variable "region"  {
  description = "GCP region code to create the K8s cluster in"
  type        = string
}

variable "vpc"  {
  description = "Self link for the GCP VPC to create the K8s cluster in"
  type        = string
}

variable "subnet"  {
  description = "Self link for the GCP VPC subnetwork to create the K8s cluster in"
  type        = string
}

variable "maintenance_window" {
  description = "Time window specified for daily maintenance operations to START in RFC3339 format"
  type        = string
  default     = "05:00"
}