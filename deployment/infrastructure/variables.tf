variable "project_id" {
  description = "project id"
  type        = string
}


variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "region" {
  description = "The region where the GKE cluster will be created"
  type        = string
  default     = "europe-central2"
}

variable "node-tyoe" {
  description = "GCP VMs to use for scaling workers"
  type        = string
  default     = "europe-central2"
}
