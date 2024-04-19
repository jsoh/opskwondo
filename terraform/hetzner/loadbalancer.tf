resource "hcloud_load_balancer" "app_demo_lb" {
  name               = "app-lb-${terraform.workspace}"
  load_balancer_type = "lb11"
  location           = var.location

  algorithm {
    type = "round_robin"
  }

  labels = {
    env  = terraform.workspace
    type = "app"
  }
}

resource "hcloud_load_balancer_target" "load_balancer_target" {
  count            = var.instances
  type             = "server"
  load_balancer_id = hcloud_load_balancer.app_demo_lb.id
  server_id        = hcloud_server.app_demo[count.index].id
}

resource "hcloud_load_balancer_service" "app_lb_service" {
  load_balancer_id = hcloud_load_balancer.app_demo_lb.id
  protocol         = var.http_protocol
  listen_port      = var.http_port
  destination_port = var.http_port

  health_check {
    protocol = var.http_protocol
    port     = var.http_port
    interval = "10"
    timeout  = "10"

    http {
      path         = "/healthz"
      response     = "OK"
      tls          = true
      status_codes = ["2??", "3??"]
    }
  }
}

resource "hcloud_load_balancer_network" "app_demo_network" {
  load_balancer_id        = hcloud_load_balancer.app_demo_lb.id
  subnet_id               = hcloud_network_subnet.app_demo_network_private_subnet.id
  enable_public_interface = "true"
}
