# Class: cmantix/cdh4pseudo
#
# Installs Cloudera CDH4:
#  * Hadoop Pseudo distributed mode
#  * Hbase pseudo distributed mode
#  * Zookeeper. 
#  * Hbase thrift
#  * Hbase Rest
#
# Parameters:
#   
# Actions:
#   Install base pacakages, validate operating system.
# Requires:
# 
# Sample Usage:
#     include cdh4pseudo
#
class cdh4pseudo {
  exec {'cdh_update':
    command => 'apt-get update',
    require => Class['cdh4pseudo::source'],
  }
  
  class {'cdh4pseudo::source': stage => 'setup', require => Class['cdh4pseudo::curl']}
  class {'cdh4pseudo::curl': stage => 'setup'}
  class {'cdh4pseudo::java': require => Exec['cdh_update']}
  class {'cdh4pseudo::pseudo': require => Class['cdh4pseudo::java']}
  
  include cdh4pseudo::source
  include cdh4pseudo::java
  include cdh4pseudo::pseudo
  include cdh4pseudo::hbase
}