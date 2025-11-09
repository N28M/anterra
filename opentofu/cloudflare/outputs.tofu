# Output values to display after applying configuration

output "zone_name" {
  description = "The name of the Cloudflare zone being managed"
  value       = data.cloudflare_zone.main.name
}

output "dns_records_created" {
  description = "List of DNS A records that were created"
  value = {
    for name, record in cloudflare_dns_record.a_records : name => {
      name    = record.name
      ip      = record.content
      proxied = record.proxied
    }
  }
}
