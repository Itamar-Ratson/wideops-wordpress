variable "project_id" {
  description = "GCP project ID."
  type        = string
  default     = "wideops-wordpress"
}

variable "region" {
  description = "Region for all regional resources."
  type        = string
  default     = "europe-north2"
}
