locals { # Terraform Locals are named values which can be assigned and used in your code. It mainly serves the purpose of reducing duplication within the Terraform code.
  deployment = {
    nodered = {
      container_count = length(var.ext_port["nodered"][terraform.workspace])
      image           = var.image["nodered"][terraform.workspace]
      int             = 1880
      ext             = var.ext_port["nodered"][terraform.workspace] # So we access the value by specifying its a variable, the ext_port variable, and the value is located within
      # the map of node red, and specifically the workspace we are working within. 
      volumes = [
        { container_path_each = "/data" }
      ]
    }
    influxdb = {
      container_count = length(var.ext_port["influxdb"][terraform.workspace])
      image           = var.image["influxdb"][terraform.workspace]
      int             = 8086
      ext             = var.ext_port["influxdb"][terraform.workspace]
      volumes = [
        { container_path_each = "/var/lib/influxdb" }
      ]
    }
    graffana = {
      container_count = length(var.ext_port["graffana"][terraform.workspace]) # This will define the port based on the workspace and the app_container
      image           = var.image["graffana"][terraform.workspace]
      int             = 3000
      ext             = var.ext_port["graffana"][terraform.workspace]
      volumes = [
        # Here we al;so need another container path, this is where dynamic blocks come into play
        { container_path_each = "/var/lib/grafana" },
        { container_path_each = "/etc/grafana" }
      ]
    }
  }
}
