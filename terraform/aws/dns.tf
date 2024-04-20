resource "cloudflare_record" "sftpgo" {
  zone_id = local.cloudflare_zone_id

  name  = local.workspace["dns_record_name"]
  type  = "A"
  value = aws_eip.sftpgo.public_ip

  proxied = false
  ttl     = 1
}
