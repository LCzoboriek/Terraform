resource "docker_container" "nodered_container" {
  name  = var.name_in
  image = var.image_in
  ports {
    internal = var.int_port_in
    external = var.ext_port_in #This is how you reference your variables
  }
  volumes {
    container_path = var.container_path_in
    host_path      = var.host_path_in #This is a way to set host paths without hardcoding, itll locate the working directory using path.cwd
  }
}