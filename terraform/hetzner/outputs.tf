output "lb_ipv4" {
  description = "Load balancer IP address"
  value       = hcloud_load_balancer.app_demo_lb.ipv4
}

output "app_servers_status" {
  value = {
    for server in hcloud_server.app_demo :
    server.name => server.status
  }
}

output "app_servers_ips" {
  value = {
    for server in hcloud_server.app_demo :
    server.name => server.ipv4_address
  }
}
