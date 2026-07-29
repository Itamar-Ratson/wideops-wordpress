variable "database_password" {
  description = "Password fixed by the supplied wp-config.php."
  type        = string
  default     = "Foxtrot01"
  sensitive   = true
}

variable "database_tier" {
  description = "Shared-core Cloud SQL tier used by the WordPress database."
  type        = string
  default     = "db-g1-small"
}

variable "image_tag" {
  description = "Non-floating tag of the WordPress image in Artifact Registry."
  type        = string
  default     = "v1"
}

variable "machine_type" {
  description = "Compute Engine machine type used by the WordPress server."
  type        = string
  default     = "e2-medium"
}

variable "subnet_cidr" {
  description = "Primary IPv4 range of the single application subnet."
  type        = string
  default     = "10.10.0.0/24"
}
