# Outputs for Proxmox resources
# Uncomment outputs as you create resources

# Example VM outputs
# output "ubuntu_server_id" {
#   description = "VM ID of the Ubuntu server"
#   value       = proxmox_virtual_environment_vm.ubuntu_server.id
# }

# output "ubuntu_server_ipv4_addresses" {
#   description = "IPv4 addresses of the Ubuntu server"
#   value       = proxmox_virtual_environment_vm.ubuntu_server.ipv4_addresses
# }

# Example LXC outputs
# output "ubuntu_lxc_id" {
#   description = "Container ID of the Ubuntu LXC"
#   value       = proxmox_virtual_environment_container.ubuntu_lxc.id
# }

# output "ubuntu_lxc_ipv4_address" {
#   description = "IPv4 address of the Ubuntu LXC"
#   value       = proxmox_virtual_environment_container.ubuntu_lxc.initialization[0].ip_config[0].ipv4[0].address
# }
