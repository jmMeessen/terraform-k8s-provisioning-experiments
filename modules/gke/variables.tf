
variable "project_id" {
  type        = string
  description = "The Google Cloud project ID to host the cluster in"
  default     = "ps-dev-201405"
}

variable "name" {
  type        = string
  description = "Name used for created cluster"
}

variable "description" {
  type    = string
  default = "I am a banana!"
}

variable "labels" {
  description = "Labels added to created cluster and node pool"
}