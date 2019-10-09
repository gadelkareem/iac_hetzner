data "hcloud_image" "db" {
  selector = "name=s3_${var.release}"
}
resource "hcloud_server" "s3" {
  name = "s3-${var.release}"
  image = "${data.hcloud_image.db.id}"
  server_type = "cx11"
  datacenter = "${var.datacenter}"
  count = 1
  labels = {
    name = "s3-${var.release}"
    app = "s3"
    release = "${var.release}"
  }
}

provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

resource "hcloud_volume" "s3" {
  name = "volume-s3-1"
  size = 100
  server_id = "${hcloud_server.s3.id}"
  labels = {
    name = "volume-s3-1"
    app = "s3"
    release = "${var.release}"
  }
}

resource "null_resource" "s3" {
  triggers {
    s3_id = "${hcloud_server.s3.id}"
  }

  connection {
    host = "${hcloud_server.s3.ipv4_address}"
    user = "${var.ssh_user}"
    port = "${var.ssh_port}"
  }

  provisioner "file" {
    source = "scripts"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /tmp/scripts/update-dns.sh ${var.s3_domain} ${local.sub_domain} ${var.cloudflare_email} ${var.cloudflare_token} || exit 0",
      "sudo bash /tmp/scripts/hcloud_volume.sh ${hcloud_volume.s3.id} ${hcloud_volume.s3.name} || exit 0",
      "sudo chown -R minio /home/minio /mnt/volume-s3-1/minio  || exit 0",
    ]
  }
}

locals {
  sub_domain = "${var.s3_sub_domain}${var.release}"
}


variable "datacenter" {}
variable "ssh_user" {}
variable "ssh_port" {}
variable "release" {}
variable "cloudflare_email" {}
variable "cloudflare_token" {}
variable "s3_access_key" {}
variable "s3_secret_key" {}
variable "s3_sub_domain" {}
variable "s3_domain" {}
