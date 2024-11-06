resource "yandex_vpc_network" "network" {
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "subnet" {
  folder_id      = var.folder_id
  zone           = var.zone
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

resource "yandex_vpc_security_group" "sg" {
  description = "Security group for ${random_string.vm_name.result}"
  network_id  = yandex_vpc_network.network.id
}

resource "yandex_vpc_security_group_rule" "egress_any" {
  security_group_binding = yandex_vpc_security_group.sg.id
  direction              = "egress"
  description            = "Allow all"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  from_port              = 0
  to_port                = 65535
  protocol               = "Any"
}

resource "yandex_vpc_security_group_rule" "ingress" {
  for_each = merge([
    for id, rule in local.ingress_security_rules : {
      for proto in rule.protocols : "${id}-${proto}" => {
        description    = "${rule.description} (${proto})"
        protocol       = proto
        v4_cidr_blocks = rule.v4_cidr_blocks
        port           = try(rule.port, null)
        from_port      = try(rule.from_port, null)
        to_port        = try(rule.to_port, null)
      }
    }
  ]...)

  security_group_binding = yandex_vpc_security_group.sg.id
  direction              = "ingress"
  description            = each.value.description
  v4_cidr_blocks         = each.value.v4_cidr_blocks
  port                   = each.value.port
  from_port              = each.value.from_port
  to_port                = each.value.to_port
  protocol               = each.value.protocol
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
  platform_id = var.platform_id

  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id     = yandex_compute_disk.disk.id
    auto_delete = false
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet.id
    nat                = true
    nat_ip_address     = yandex_vpc_address.public_ip.external_ipv4_address[0].address
    security_group_ids = [yandex_vpc_security_group.sg.id]
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "${random_string.username.result}:${tls_private_key.ssh_key.public_key_openssh}"
  }

  connection {
    type        = "ssh"
    host        = self.network_interface[0].nat_ip_address
    user        = random_string.username.result
    private_key = tls_private_key.ssh_key.private_key_openssh
  }

  provisioner "remote-exec" {
    inline = [
      "curl -O ${var.install_script_url}",
      "chmod +x openvpn-install.sh",
      "AUTO_INSTALL=y ENDPOINT=${self.network_interface[0].nat_ip_address} CLIENT=${random_string.username.result} sudo -E ./openvpn-install.sh",
    ]
  }
}

resource "local_sensitive_file" "ssh_private_key" {
  content         = tls_private_key.ssh_key.private_key_openssh
  filename        = "local/${random_string.username.result}.pem"
  file_permission = "0600"
}

resource "null_resource" "openvpn_config" {
  depends_on = [yandex_compute_instance.vm]

  provisioner "local-exec" {
    command = <<-EOT
        scp \
          -o UserKnownHostsFile=/dev/null \
          -o StrictHostKeyChecking=no \
          -o AddKeysToAgent=no \
          -i local/${random_string.username.result}.pem \
          ${random_string.username.result}@${yandex_vpc_address.public_ip.external_ipv4_address[0].address}:${random_string.username.result}.ovpn \
          local/
    EOT
  }

  provisioner "local-exec" {
    command    = "open local/${random_string.username.result}.ovpn"
    on_failure = continue
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf local"
  }
}
