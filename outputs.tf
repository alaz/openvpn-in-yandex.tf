output "ip_address" {
  value = yandex_vpc_address.public_ip.external_ipv4_address[0].address
}

output "private_key" {
  value = nonsensitive(tls_private_key.ssh_key.private_key_openssh)
}
