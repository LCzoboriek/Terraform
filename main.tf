locals { # Terraform Locals are named values which can be assigned and used in your code. It mainly serves the purpose of reducing duplication within the Terraform code.
  deployment = {
    nodered = {
      container_count = length(var.ext_port["nodered"][terraform.workspace])
      image = var.image["nodered"][terraform.workspace]
      int   = 1880
      ext   = var.ext_port["nodered"][terraform.workspace] # So we access the value by specifying its a variable, the ext_port variable, and the value is located within
      # the map of node red, and specifically the workspace we are working within. 
      container_path = "/data"
    }
    influxdb = {
      container_count = length(var.ext_port["influxdb"][terraform.workspace])
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

module "container" {
  source   = "./container"
  for_each = local.deployment
  count_in = each.value.container_count
  # count             = local.container_count
  name_in           = each.key
  image_in          = module.image["nodered"].image_out
  int_port_in       = each.value.int
  ext_port_in       = each.value.ext
  container_path_in = each.value.container_path

}