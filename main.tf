terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "docker" {
  #This will be left empty as its local
}

resource "null_resource" "dockervol" {
  provisioner "local-exec" {
    command = "mkdir noderedvol/ || true && sudo chown -R 1000:1000 noderedvol/"
  }
}

resource "docker_image" "nodered_image" {       #this resource requires a name and type
  name = var.image[terraform.workspace] #This must match the name on docker hub
}

resource "random_string" "random" {
  count   = local.container_count
  length  = 4
  special = false
  upper   = false
}

resource "docker_container" "nodered_container" {
  count = local.container_count
  name  = join("-", ["nodered", terraform.workspace, random_string.random[count.index].result])
  image = docker_image.nodered_image.name
  ports {
    internal = var.internal_port
    external = var.ext_port[terraform.workspace][count.index] #This is how you reference your variables
  }
  volumes {
    container_path = "/data"
    host_path      = "${path.cwd}/noderedvol" #This is a way to set host paths without hardcoding, itll locate the working directory using path.cwd
  }

}



