resource "hcloud_ssh_key" "default" {
  name       = "hetzner_ssh_key"
  public_key = file("./ssh/tf_deploy.pub")
}
