# output "container-name" {
#   value       = module.container[*].container-name
#   description = "The name of the container"
# }

# output "IP-Address" {
#   value       = flatten(module.container[*].ip-address)
#   description = "The ip address of the container and external port"
# }


output "application_access" {
  value       = [for x in module.container[*] : x]
  description = "The name and socket for each application"
}
