data "hcloud_image" "db" {
  selector = "name=db_${var.release}"
}

resource "hcloud_server" "db" {
  name = "db-${var.release}"
  image = "${data.hcloud_image.db.id}"
  server_type = "cx21"
  datacenter = "${var.datacenter}"
  count = 1
  labels = {
    name = "db-${var.release}"
    app = "db"
    release = "${var.release}"
  }
}


resource "null_resource" "db" {
  triggers {
    s3_id = "${hcloud_server.db.id}"
  }

  connection {
    host = "${hcloud_server.db.ipv4_address}"
    user = "${var.ssh_user}"
    port = "${var.ssh_port}"
  }

  provisioner "file" {
    source = "scripts/postgresql/files/postgresql-backup.sh"
    destination = "/tmp/postgresql-backup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -H bash /tmp/postgresql-backup.sh restore all || exit 0",
    ]
  }
}


variable "datacenter" {}
variable "ssh_user" {}
variable "ssh_port" {}
variable "release" {}
