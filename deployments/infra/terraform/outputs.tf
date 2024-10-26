output "app_server_dns" {
  value = aws_eip.app_eip.public_dns
}

output "app_server_ip" {
  value = aws_eip.app_eip.public_ip
}

output "server_private_key" {
  value     = tls_private_key.app_server_key.private_key_pem
  sensitive = true
}
