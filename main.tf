locals { # Terraform Locals are named values which can be assigned and used in your code. It mainly serves the purpose of reducing duplication within the Terraform code.
  deployment = {
    nodered = {
      image = var.image["nodered"][terraform.workspace]
    }
    influxdb = {
      image = var.image["influxdb"][terraform.workspace]
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
  count   = local.container_count
  length  = 4
  special = false
  upper   = false
}

module "container" {
  source            = "./container"
  count             = local.container_count
  name_in           = join("-", ["nodered", terraform.workspace, random_string.random[count.index].result])
  image_in          = module.image["nodered"].image_out
  int_port_in       = var.internal_port
  ext_port_in       = var.ext_port[terraform.workspace][count.index] #This is how you reference your variables
  container_path_in = "/data"

}