variable "token" {
  type        = string
  description = "Security token or IAM token"
  sensitive   = true
}

variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "zone" {
  type    = string
  default = "ru-central1-d"
}
