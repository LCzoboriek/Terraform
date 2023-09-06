locals { # Terraform Locals are named values which can be assigned and used in your code. It mainly serves the purpose of reducing duplication within the Terraform code.
  deployment = {
    nodered = {
      image = var.image["nodered"][terraform.workspace]
      int   = 1880
      ext   = var.ext_port["nodered"][terraform.workspace] # So we access the value by specifying its a variable, the ext_port variable, and the value is located within
      # the map of node red, and specifically the workspace we are working within. 
      container_path = "/data"
    }
    influxdb = {
      image          = var.image["influxdb"][terraform.workspace]
      int            = 8086
      ext            = var.ext_port["influxdb"][terraform.workspace]
      container_path = "/var/lib/influxdb"
    }
  }
}

# Terraform console
# To access these locals its utilising key/value pairs
# local.deployment.nodered.image  will give the result of "nodered/node-red:latest"
# 

module "image" {
  source = "./image"
  # Anything under the source, is associated as an attribute
  # they need to be present in both places
  for_each = local.deployment
  image_in = each.value.image
}


resource "random_string" "random" {
  for_each = local.deployment
  length   = 4
  special  = false
  upper    = false
}

module "container" {
  source   = "./container"
  for_each = local.deployment
  # count             = local.container_count
  name_in           = join("-", [each.key, terraform.workspace, random_string.random[each.key].result])
  image_in          = module.image["nodered"].image_out
  int_port_in       = each.value.int
  ext_port_in       = each.value.ext[0]
  container_path_in = each.value.container_path

}