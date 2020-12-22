
variable "project" {
    type        = string
    description = "GCP project"
    # No default - must be supplied
}

variable "region"  {
    type        = string
    description = "GCP region"
    # No default - must be supplied
}

variable "network_name" {
    type        = string
    default     = "kl-network"
    description = "Name of the network to create"
}

variable "subnet_cidr" {
    type        = string
    default     = "10.0.0.0/16"
    description = "CIDR for the regional subnet for GKE"
}

variable "flowlogs_interval" {
    type        = string
    default     = "INTERVAL_10_MIN"
    description = "Interval for collection of VPC Flow Logs"
}

variable "flowlogs_sampling" {
    type        = number
    default     = 0.5
    description = "Sample rate for collection of VPC Flow Logs (0->1)"
}

variable "vpc_peering_range_size" {
    type        = number
    default     = 17
    description = "Sample rate for collection of VPC Flow Logs (0->1)"
}