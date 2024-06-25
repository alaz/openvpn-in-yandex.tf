data "yandex_compute_image" "image" {
  family    = "ubuntu-2404-lts-oslogin"
  folder_id = "standard-images"
}

resource "random_string" "vm_name" {
  length  = 4
  upper   = false
  special = false
}
