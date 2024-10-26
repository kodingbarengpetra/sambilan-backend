data "github_repository" "app" {
  name = var.repository_name
}

resource "github_actions_secret" "app_server_host" {
  repository      = data.github_repository.app.name
  secret_name     = "APP_SERVER_HOST"
  plaintext_value = aws_eip.app_eip.public_ip
}

resource "github_actions_secret" "app_server_key" {
  repository      = data.github_repository.app.name
  secret_name     = "APP_SERVER_KEY"
  plaintext_value = tls_private_key.app_server_key.private_key_pem
}
