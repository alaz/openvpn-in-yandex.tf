output "ip_address" {
  value = yandex_vpc_address.public_ip.external_ipv4_address[0].address
}

output "username" {
  value = random_string.username.result
}
