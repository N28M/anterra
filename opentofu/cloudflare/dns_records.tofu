# Data source to get zone information
data "cloudflare_zone" "main" {
  zone_id = local.cloudflare_zone_id
}

# DNS A Records
# Use for_each to create multiple records from a local map
locals {
  a_records = {
    #----------------------------------------------------------------
    # Internal Records (Homelab Reverse Proxy)
    # Points to internal Caddy instance
    # proxied = false (internal IPs cannot use Cloudflare proxy)
    #----------------------------------------------------------------
    "pve" = {
      content = local.homelab_reverse_proxy_ip
    }
    "ui" = {
      content = local.homelab_reverse_proxy_ip
    }
    #----------------------------------------------------------------
    # External Records (VPS Reverse Proxy)
    # Points to VPS Caddy instance
    # proxied = true (enables Cloudflare DDoS protection, caching, etc.)
    #----------------------------------------------------------------
    "plex" = {
      content = local.vps_reverse_proxy_ip
      proxied = true
    }
  }
}

# Create A records using for_each
resource "cloudflare_dns_record" "a_records" {
  for_each = local.a_records

  zone_id = local.cloudflare_zone_id
  name    = each.key
  content = each.value.content
  type    = "A"
  proxied = lookup(each.value, "proxied", false)
  ttl     = lookup(each.value, "ttl", 1)

  comment = "Managed by OpenTofu"
}
