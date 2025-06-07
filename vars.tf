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

variable "install_script_url" {
  type    = string
  default = "https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh"
}

locals {
  ingress_security_rules = {
    "ssh" = {
      protocols      = ["TCP"]
      v4_cidr_blocks = ["0.0.0.0/0"]
      description    = "Allow SSH access"
      port           = 22
    },
    "icmp" = {
      protocols      = ["ICMP"]
      v4_cidr_blocks = ["0.0.0.0/0"]
      description    = "Allow all"
      from_port      = 0
      to_port        = 65535
    },
    "ovpn" = {
      protocols      = ["TCP", "UDP"]
      v4_cidr_blocks = ["0.0.0.0/0"]
      description    = "Allow OpenVPN"
      port           = 1194
    },
  }
}
