resource "hcloud_server" "app_demo" {
  count       = var.instances
  name        = "app-server-${terraform.workspace}-${count.index}"
  image       = var.os_type
  server_type = var.server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]
  user_data   = file("config/user_data.yml")

  labels = {
    env  = terraform.workspace
    type = "app"
  }
}

resource "hcloud_volume" "app_demo_volume" {
  count    = var.instances
  name     = "app-server-volume-${terraform.workspace}-${count.index}"
  size     = var.disk_size
  location = var.location
  format   = "xfs"

  labels = {
    env  = terraform.workspace
    type = "app"
  }
}

resource "hcloud_volume_attachment" "app_demo_volume_attachment" {
  count     = var.instances
  volume_id = hcloud_volume.app_demo_volume[count.index].id
  server_id = hcloud_server.app_demo[count.index].id
  automount = true
}
