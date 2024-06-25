resource "yandex_vpc_network" "network" {
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "subnet" {
  folder_id      = var.folder_id
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.1.0.0/24"]
}

resource "yandex_vpc_address" "public_ip" {
  description = "IP address for ${random_string.vm_name.result}"
  folder_id   = var.folder_id

  external_ipv4_address {
    zone_id = var.zone
  }
}

resource "yandex_compute_disk" "disk" {
  description = "Disk for ${random_string.vm_name.result}"
  folder_id   = var.folder_id
  zone        = var.zone
  image_id    = data.yandex_compute_image.image.id
  size        = 10
  type        = "network-hdd"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "yandex_compute_instance" "vm" {
  name        = "vm-${random_string.vm_name.result}"
  folder_id   = var.folder_id
  zone        = var.zone
  platform_id = "standard-v2"

  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk.id
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.subnet.id
    nat_ip_address = yandex_vpc_address.public_ip.external_ipv4_address[0].address
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    # ssh_keys  = "user:${tls_private_key.ssh_key.public_key_openssh}"
    user-data = <<-EOT
      users:
        - name: user
            groups: sudo
            shell: /bin/bash
            sudo: 'ALL=(ALL) NOPASSWD:ALL'
            ssh-authorized-keys:
              - ${tls_private_key.ssh_key.public_key_openssh}
    EOT
  }
}
