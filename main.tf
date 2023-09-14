

# Graffana task
# Add a new container 
# Deploy with node red and influxdb
#in docs youll find images, ports, etc
# the container path is set above
# make sure you define all the variables in the right files
# 1 instance only



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
  source      = "./container"
  for_each    = local.deployment
  count_in    = each.value.container_count
  name_in     = each.key
  image_in    = module.image[each.key].image_out
  int_port_in = each.value.int
  ext_port_in = each.value.ext
  volumes_in  = each.value.volumes

}