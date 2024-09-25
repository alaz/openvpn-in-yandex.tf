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

variable "platform_id" {
  type        = string
  description = "VM platform, see https://yandex.cloud/ru/docs/compute/concepts/vm-platforms"
  default     = "standard-v2"
}

variable "install_script_url" {
  type    = string
  default = "https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh"
}
