data "yandex_compute_image" "image" {
  family    = "debian-11-oslogin"
  folder_id = "standard-images"
}

resource "random_string" "vm_name" {
  length  = 4
  upper   = false
  special = false
}

resource "random_string" "username" {
  length  = 5
  upper   = false
  special = false
  numeric = false
}
