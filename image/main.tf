resource "docker_image" "container_image" { #this resource requires a name and type
  name = var.image_in                       #This must match the name on docker hub
}
