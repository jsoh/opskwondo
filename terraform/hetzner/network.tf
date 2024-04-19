resource "hcloud_network" "app_demo_network_private" {
  name     = "hc_private"
  ip_range = var.ip_range
}

resource "hcloud_server_network" "app_demo_network" {
  count     = var.instances
  server_id = hcloud_server.app_demo[count.index].id
  subnet_id = hcloud_network_subnet.app_demo_network_private_subnet.id
}

resource "hcloud_network_subnet" "app_demo_network_private_subnet" {
  network_id   = hcloud_network.app_demo_network_private.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = var.ip_range
}
