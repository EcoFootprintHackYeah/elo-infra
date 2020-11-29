terraform {
  required_version = "~> 0.13"
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "1.17.0"
    }
  }
}

provider "scaleway" {
  zone = "fr-par-1"
}

resource "scaleway_instance_ip" "api" {}

resource "scaleway_instance_server" "api" {
  type  = "DEV1-S"
  image = "ubuntu_focal"
  tags  = ["api", "hackathon", "NodeJs"]
  name  = "elo-eco-api"
  ip_id = scaleway_instance_ip.api.id
}


resource "scaleway_rdb_instance_beta" main {
  name           = "hackyeah-rdb"
  node_type      = "db-dev-s"
  engine         = "PostgreSQL-12"
  is_ha_cluster  = false    
  disable_backup = true
  user_name      = "YYYYYY"
  password       = "XXXXXX"
}

resource "null_resource" "api" {
  triggers = {
    server_id = scaleway_instance_server.api.id
    playbook  = md5(file("deploy.yml"))
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${scaleway_instance_ip.api.address}, deploy.yml"
  }
}
