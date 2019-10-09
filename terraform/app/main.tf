data "hcloud_image" "app" {
  selector = "name=app_${var.release}"
}
resource "hcloud_server" "app" {
  name = "app-${var.release}"
  image = "${data.hcloud_image.app.id}"
  server_type = "cx11"
  datacenter = "${var.datacenter}"
  count = 1
  labels = {
    name = "app-${var.release}"
    app = "app"
    release = "${var.release}"
  }
}

resource "hcloud_floating_ip" "app" {
  type = "ipv4"
  server_id = "${hcloud_server.app.id}"
}

resource "null_resource" "app" {
  triggers {
    app_id = "${hcloud_server.app.id}"
  }

  connection {
    host = "${hcloud_server.app.ipv4_address}"
    user = "${var.ssh_user}"
    port = "${var.ssh_port}"
  }

  provisioner "file" {
    source = "scripts"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /tmp/scripts/hcloud_floating_ip.sh ${hcloud_floating_ip.app.ip_address}",
    ]
  }
}
variable "datacenter" {}
variable "ssh_user" {}
variable "ssh_port" {}
variable "release" {}
