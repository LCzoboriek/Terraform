

module "nodered_image" {
  source = "./image"
  # Anything under the source, is associated as an attribute
  # they need to be present in both places
  image_in = var.image[terraform.workspace]
}


module "influxdb_image" {
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
  count = local.container_count
  name_in  = join("-", ["nodered", terraform.workspace, random_string.random[count.index].result])
  image_in = module.image.image_out
  int_port_in = var.internal_port
  ext_port_in = var.ext_port[terraform.workspace][count.index] #This is how you reference your variables
  container_path_in = "/data"

}