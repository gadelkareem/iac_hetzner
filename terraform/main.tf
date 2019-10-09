provider "hcloud" {
  token = "${var.hcloud_token}"
}

module "s3" {
  source = "./s3"
  datacenter = "${var.datacenter}"
  ssh_user = "${var.ssh_user}"
  ssh_port = "${var.ssh_port}"
  release = "${var.release}"
  cloudflare_email = "${var.cloudflare_email}"
  cloudflare_token = "${var.cloudflare_token}"
  s3_access_key = "${var.s3_access_key}"
  s3_secret_key = "${var.s3_secret_key}"
  s3_domain = "${var.s3_domain}"
  s3_sub_domain = "${var.s3_sub_domain}"
}

module "db" {
  source = "./db"
  datacenter = "${var.datacenter}"
  ssh_user = "${var.ssh_user}"
  ssh_port = "${var.ssh_port}"
  release = "${var.release}"
}

module "app" {
  source = "./app"
  datacenter = "${var.datacenter}"
  ssh_user = "${var.ssh_user}"
  ssh_port = "${var.ssh_port}"
  release = "${var.release}"
}


variable "hcloud_token" {}
variable "datacenter" {}
variable "ssh_user" {}
variable "ssh_port" {}
variable "release" {}
variable "cloudflare_email" {}
variable "cloudflare_token" {}
variable "s3_access_key" {}
variable "s3_secret_key" {}
variable "s3_domain" {}
variable "s3_sub_domain" {}


