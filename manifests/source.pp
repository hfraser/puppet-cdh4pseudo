# Class: cmantix/cdh4pseudo::source
#
# Cloudera debian repo and Java7 PPA
#
# Parameters:
#   
# Actions:
#     /etc/apt/sources.list.d/cdh4.list with cloudera key and Java7 Key
# Requires:
#     cdh4pseudo::curl
# Sample Usage:
#     include cdh4pseudo::source
#
class cdh4pseudo::source{
  file { "cdh4-sourcelist":
    path    => "/etc/apt/sources.list.d/cdh4.list",
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    content => template("cdh4pseudo/cdh4.list.erb")
  }
  
  $os_downcase = downcase($::operatingsystem)
  
  exec {'add-cdh4-key':
    command => "curl -s http://archive.cloudera.com/cdh4/${os_downcase}/${::lsbdistcodename}/${::architecture}/cdh/archive.key | sudo apt-key add -",
    require => [File['cdh4-sourcelist'], Package['curl']]
  }
  
  exec {'add-java-key':
    command => "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886",
    require => File['cdh4-sourcelist']
  }
}