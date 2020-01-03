variable "owner" {
  type        = "string"
  description = "Owner labels on resources are set to this value"
}

variable "workspace" {
  type        = "string"
  description = "Name of workspace that built this resource"
}

variable "credentials" {
  type        = "string"
  description = "Filename for GCP credentials file"
}

variable "project_id" {
  type        = "string"
  description = "The Google Cloud project ID to host the cluster in"
  default     = "ps-dev-201405"
}

variable "description" {
  type    = "string"
  default = "I am a banana!"
}

variable "region" {
  type        = "string"
  description = "GCP region"
  default     = "us-central-1"
}
variable "zone" {
  type        = "string"
  description = "GCP zone"
  default     = "us-central1-a"
}
