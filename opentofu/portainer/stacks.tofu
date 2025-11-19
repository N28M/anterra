# Watchtower stack - automatically updates Docker containers
resource "portainer_stack" "watchtower" {
  name              = "watchtower"
  deployment_type  = "standalone"
  method            = "string"
  endpoint_id      = var.portainer_endpoint_id
  stack_file_content = templatefile("${path.module}/compose-files/watchtower.yaml.tpl", {
    docker_user_puid   = var.docker_user_puid
    docker_user_pgid   = var.docker_user_pgid
    docker_timezone    = var.docker_timezone
    docker_config_path = var.docker_config_path
  })
}
