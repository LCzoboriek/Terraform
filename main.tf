resource "null_resource" "dockervol" {
  provisioner "local-exec" {
    command = "mkdir noderedvol/ || true && sudo chown -R 1000:1000 noderedvol/"
  }
}

module "image" {
  source = "./image"
  # Anything under the source, is associated as an attribute
  # they need to be present in both places
  image_in = var.image[terraform.workspace]
}

resource "random_string" "random" {
  count   = local.container_count
  length  = 4
  special = false
  upper   = false
}

module "container" {
  source = "./container"
  depends_on = [null_resource.dockervol]
  count = local.container_count
  name_in  = join("-", ["nodered", terraform.workspace, random_string.random[count.index].result])
  image_in = module.image.image_out
  int_port_in = var.internal_port
  ext_port_in = var.ext_port[terraform.workspace][count.index] #This is how you reference your variables
  container_path_in = "/data"
  host_path_in      = "${path.cwd}/noderedvol" #This is a way to set host paths without hardcoding, itll locate the working directory using path.cwd

}