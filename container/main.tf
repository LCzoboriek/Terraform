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
      volume_name = module.volume[count.index].volume_output[volumes.key] # Now that we're not accessing count, we use the volumes.key, to iterate through them
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

module "volume" {
  source       = "./volume"
  count        = var.count_in # We need this module to be run the same amount of times as the docker container
  volume_count = length(var.volumes_in)
  volume_name  = "${var.name_in}-${terraform.workspace}-${random_string.random[count.index].result}-volume"
}