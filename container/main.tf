resource "random_string" "random" {
  count   = var.count_in
  length  = 4
  special = false
  upper   = false
}

resource "docker_container" "app_container" {
  count = var.count_in
  name  = join("-", [var.name_in, terraform.workspace, random_string.random[count.index].result])
  image = var.image_in
  ports {
    internal = var.int_port_in
    external = var.ext_port_in[count.index] #This is how you reference your variables
  }
  dynamic "volumes" {
    for_each = var.volumes_in
    content {
      container_path = volumes.value["container_path_each"] # Here we will be accessing the value of volumes, which is linked to the locals.tf, 
      # and specifically accessing the value of those of which match container_path_each
      volume_name = docker_volume.container_volume[volumes.key].name # Now that we're not accessing count, we use the volumes.key, to iterate through them
    }
  }
  provisioner "local-exec" {
    when    = create
    command = "echo ${self.name}: http://${self.network_data[0].ip_address}:${self.ports[0].external}  >>  containers.txt"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f containers.txt"
  }
}

resource "docker_volume" "container_volume" {
  count = length(var.volumes_in)
  name  = "${var.name_in}-${count.index}-volume"
  lifecycle {
    prevent_destroy = false
  }
  provisioner "local-exec" {
    when       = destroy
    command    = "mkdir ${path.cwd}/../backup/"
    on_failure = continue
  }
  provisioner "local-exec" {
    when       = destroy
    command    = "sudo tar -czvf ${path.cwd}/../backup/${self.name}.tar.gz ${self.mountpoint}/"
    on_failure = fail
  }
}