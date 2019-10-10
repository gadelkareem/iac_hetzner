# Infrastructure as code on Hetzner

Provisions infrastructure for a Golang application on Hetzner cloud. The code packs a Golang, PostgreSQL, S3(minio) images using packer then launches the infrastructure using Terraform with helpers such as bash, hcloud and supfile. 
The main reason behind the setup is the make it as cost effective as possible to launch a small to medium project.

# Provision Infrastructure
- Make sure you have [hcloud](https://github.com/hetznercloud/cli), [supfile](https://github.com/pressly/sup), [packer](https://www.packer.io/) and [terraform](https://www.terraform.io/) installed locally.
- Start a new project on Hetzner and get your API token. 
- Rename `vars.example.json` to `vars.json` and add your config/secrets.
- Replace `ssh_authorized_keys` in `cloud-init/base.yml` with your public key.
- Run `./infra.sh up` to start the provisioning


# Destroy Infrastructure
- Run `./infra.sh down` to remove all images, volumes and instances.

# Minio GUI
`https://s3-1.example.com/` where example.com is your domain and notice we update cloudflare DNS automatically while provisioning.



