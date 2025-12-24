# # VM configurations for Proxmox

# # Test VM with GPU passthrough configuration (based on mediacenter setup)
# resource "proxmox_virtual_environment_vm" "mediacenter_test" {
#   name        = "mediacenter-test"
#   description = "Test Plex Media Server with Intel GPU passthrough"
#   node_name   = var.proxmox_node_1

#   # Don't start automatically (GPU is used by mediacenter VM 1002)
#   started = false

#   cpu {
#     cores = 4
#     type  = "host"
#     flags = ["+pcid"]  # CPU flags for better GPU compatibility
#   }

#   memory {
#     dedicated = 8192  # 8GB RAM
#   }

#   network_device {
#     bridge = "vmbr0"
#     model  = "virtio"
#   }

#   disk {
#     datastore_id = "local-lvm"
#     interface    = "scsi0"
#     size         = 64
#     file_format  = "raw"
#     discard      = "on"
#     ssd          = true
#     cache        = "writeback"
#   }

#   # PCI passthrough for GPU using hardware mapping
#   hostpci {
#     device  = "hostpci0"
#     mapping = "intel-igpu"  # Name of the hardware mapping in Proxmox
#     pcie    = true
#     rombar  = false  # Required for Intel iGPU
#   }

#   # Disable VGA when using GPU passthrough
#   vga {
#     type = "none"
#   }

#   operating_system {
#     type = "l26"
#   }

#   bios = "ovmf"

#   efi_disk {
#     datastore_id = "local-lvm"
#     type         = "4m"
#   }

#   machine       = "q35"
#   scsi_hardware = "virtio-scsi-single"

#   agent {
#     enabled = true
#   }

#   tags = ["opentofu", "plex", "gpu-passthrough", "test", "mediacenter"]
# }
