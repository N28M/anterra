# Example LXC container configurations for Proxmox
# These are templates - uncomment and customize as needed

# Example: Basic Ubuntu LXC container
# resource "proxmox_virtual_environment_container" "ubuntu_lxc" {
#   description = "Ubuntu LXC container managed by OpenTofu"
#   node_name   = "pve"  # Change to your Proxmox node name
#   vm_id       = 200  # Optional: specify container ID
#
#   # Container will be created but not started automatically
#   started = false
#
#   # Operating system template
#   operating_system {
#     template_file_id = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
#     # Download templates via Proxmox UI or CLI: pveam update && pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst
#     type             = "ubuntu"
#   }
#
#   # Container resources
#   cpu {
#     cores = 2
#   }
#
#   memory {
#     dedicated = 1024  # 1GB RAM
#     swap      = 512   # 512MB swap
#   }
#
#   # Root disk
#   disk {
#     datastore_id = "local-lvm"
#     size         = 8  # 8GB root disk
#   }
#
#   # Network interface
#   network_interface {
#     name   = "eth0"
#     bridge = "vmbr0"
#     # Use DHCP
#     enabled = true
#     # Or use static IP:
#     # ipv4_address = "192.168.1.100/24"
#     # ipv4_gateway = "192.168.1.1"
#   }
#
#   # Container features
#   features {
#     nesting = false  # Enable for Docker-in-LXC
#     fuse    = false  # Enable for FUSE filesystems
#   }
#
#   # Initialization (like cloud-init for containers)
#   initialization {
#     hostname = "ubuntu-lxc"
#
#     ip_config {
#       ipv4 {
#         address = "dhcp"
#       }
#     }
#
#     user_account {
#       keys = ["ssh-rsa AAAAB3..."]  # Add your SSH public key
#     }
#   }
#
#   # Tags for organization
#   tags = ["opentofu", "lxc", "ubuntu"]
# }

# Example: Docker host LXC (privileged container with nesting)
# resource "proxmox_virtual_environment_container" "docker_host" {
#   description = "Docker host LXC container"
#   node_name   = "pve"
#
#   # Privileged container required for Docker
#   unprivileged = false
#
#   operating_system {
#     template_file_id = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
#     type             = "ubuntu"
#   }
#
#   cpu {
#     cores = 4
#   }
#
#   memory {
#     dedicated = 4096
#     swap      = 2048
#   }
#
#   disk {
#     datastore_id = "local-lvm"
#     size         = 32
#   }
#
#   network_interface {
#     name   = "eth0"
#     bridge = "vmbr0"
#   }
#
#   # Enable nesting for Docker
#   features {
#     nesting = true
#     keyctl  = true  # Required for systemd
#     fuse    = true
#   }
#
#   initialization {
#     hostname = "docker-host"
#
#     ip_config {
#       ipv4 {
#         address = "192.168.1.110/24"
#         gateway = "192.168.1.1"
#       }
#     }
#
#     user_account {
#       keys = ["ssh-rsa AAAAB3..."]
#     }
#   }
#
#   # Container startup options
#   startup {
#     order      = 1
#     up_delay   = 30
#     down_delay = 30
#   }
#
#   tags = ["opentofu", "lxc", "docker"]
# }

# Example: Lightweight service container
# resource "proxmox_virtual_environment_container" "nginx_proxy" {
#   description = "Nginx reverse proxy LXC"
#   node_name   = "pve"
#
#   operating_system {
#     template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
#     type             = "debian"
#   }
#
#   cpu {
#     cores = 1
#   }
#
#   memory {
#     dedicated = 512
#     swap      = 256
#   }
#
#   disk {
#     datastore_id = "local-lvm"
#     size         = 4
#   }
#
#   network_interface {
#     name   = "eth0"
#     bridge = "vmbr0"
#   }
#
#   initialization {
#     hostname = "nginx-proxy"
#
#     ip_config {
#       ipv4 {
#         address = "192.168.1.120/24"
#         gateway = "192.168.1.1"
#       }
#     }
#
#     user_account {
#       keys = ["ssh-rsa AAAAB3..."]
#     }
#   }
#
#   # Console settings
#   console {
#     enabled    = true
#     type       = "shell"
#     tty_count  = 2
#   }
#
#   tags = ["opentofu", "lxc", "nginx"]
# }

# Example: Mount points for LXC (bind mounts from host)
# resource "proxmox_virtual_environment_container" "container_with_mounts" {
#   description = "LXC with bind mounts"
#   node_name   = "pve"
#
#   operating_system {
#     template_file_id = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
#     type             = "ubuntu"
#   }
#
#   cpu {
#     cores = 2
#   }
#
#   memory {
#     dedicated = 2048
#   }
#
#   disk {
#     datastore_id = "local-lvm"
#     size         = 16
#   }
#
#   # Additional mount point from host
#   mount_point {
#     volume = "/mnt/host-data"  # Host path
#     path   = "/data"            # Container path
#     # For unprivileged containers, ensure UIDs match or use ACLs
#   }
#
#   network_interface {
#     name   = "eth0"
#     bridge = "vmbr0"
#   }
#
#   initialization {
#     hostname = "container-with-mounts"
#
#     ip_config {
#       ipv4 {
#         address = "dhcp"
#       }
#     }
#   }
#
#   tags = ["opentofu", "lxc"]
# }
