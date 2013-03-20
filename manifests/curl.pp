# Class: cmantix/cdh4pseudo::curl
#
# Install curl ... dont ask me why this is not standard on servers ... I ALWAYS use it
#
# Parameters:
#   
# Actions:
#     install curl
# Requires:
#     
# Sample Usage:
#     include cdh4pseudo::curl
#
class cdh4pseudo::curl {
  exec {'tmp-update':
    command => 'apt-get update'
  }
  
  Exec['tmp-update']->Package <| |>
  package {'curl': ensure => latest }
}