# Class: cmantix/cdh4pseudo::pseudo
#
# Install Apache Hadoop in pseudo distributed mode according to cloudera's instructions.
#
# Parameters:
#   
# Actions:
#     Completely install hadoop in pseudo ditributed mode. 
# Requires:
#     cdh4pseudo::java
# Sample Usage:
#     include cdh4pseudo::pseudo
#
class cdh4pseudo::pseudo {
  package { 'hadoop-conf-pseudo':
    ensure  => present,
  }
  
  exec { 'format-hdfs-partition':
    unless => 'ls /root/hadooptmp.lock',
    command => 'sudo -u hdfs hdfs namenode -format',
    require => Package['hadoop-conf-pseudo']
  }
  
  service {'hadoop-hdfs-datanode': ensure => running, require => Exec['format-hdfs-partition']}
  service {'hadoop-hdfs-namenode': ensure => running, require => Exec['format-hdfs-partition']}
  service {'hadoop-hdfs-secondarynamenode': ensure => running, require => Exec['format-hdfs-partition']}
  
  exec { 'rm-tmp-hdfs':
    unless => 'ls /root/hadooptmp.lock',
    command => 'sudo -u hdfs hadoop fs -rm -r /tmp ; touch /root/hadooptmp.lock',
    require => [Service['hadoop-hdfs-datanode'],Service['hadoop-hdfs-namenode'],Service['hadoop-hdfs-secondarynamenode']]
  }
  
  
  exec { 'mkdir-tmp-hdfs-tmp':
    unless => 'sudo -u hdfs hadoop fs -ls /tmp',
    command => 'sudo -u hdfs hadoop fs -mkdir /tmp',
    require => Exec['rm-tmp-hdfs']
  }
  
  exec { 'mkdir-tmp-hdfs-tmp-hadoop-yarn-staging':
    unless => 'sudo -u hdfs hadoop fs -ls /tmp/hadoop-yarn/staging',
    command => 'sudo -u hdfs hadoop fs -mkdir /tmp/hadoop-yarn/staging',
    require => Exec['mkdir-tmp-hdfs-tmp']
  }
  
  exec { 'mkdir-tmp-hdfs-tmp-hadoop-yarn-staging-history-done_intermediate':
    unless => 'sudo -u hdfs hadoop fs -ls /tmp/hadoop-yarn/staging/history/done_intermediate',
    command => 'sudo -u hdfs hadoop fs -mkdir /tmp/hadoop-yarn/staging/history/done_intermediate',
    require => Exec['mkdir-tmp-hdfs-tmp-hadoop-yarn-staging']
  }
  
  exec { "chmod-tmp-hdfs-tmp":
    command => 'sudo -u hdfs hadoop fs -chmod -R 1777 /tmp',
    require => Exec['mkdir-tmp-hdfs-tmp-hadoop-yarn-staging-history-done_intermediate']
  }
  
  exec { 'chown-tmp-hdfs':
    command => 'sudo -u hdfs hadoop fs -chown -R mapred:mapred /tmp/hadoop-yarn/staging',
    require => Exec['chmod-tmp-hdfs-tmp']
  }
  
  exec { 'mkdir-tmp-hdfs-log':
    unless => 'sudo -u hdfs hadoop fs -ls /var/log/hadoop-yarn',
    command => 'sudo -u hdfs hadoop fs -mkdir /var/log/hadoop-yarn',
    require => Exec['chown-tmp-hdfs']
  }
  
  exec { 'chown-tmp-hdfs-log':
    command => 'sudo -u hdfs hadoop fs -chown yarn:mapred /var/log/hadoop-yarn',
    require => Exec['mkdir-tmp-hdfs-log']
  }
  
  service {'hadoop-yarn-resourcemanager':
    ensure => running,
    require => Exec['chown-tmp-hdfs-log']
  }
  
  service {'hadoop-yarn-nodemanager':
    ensure => running,
    require => Exec['chown-tmp-hdfs-log']
  }
  
  service {'hadoop-mapreduce-historyserver':
    ensure => running,
    require => Exec['chown-tmp-hdfs-log']
  }
  
  # create vagrant user directories
  exec { 'vagrant-hdfs-dir':
    unless  => 'sudo -u hdfs hadoop fs -ls /user/vagrant',
    command => 'sudo -u hdfs hadoop fs -mkdir /user/vagrant',
    require => Service['hadoop-mapreduce-historyserver']
  }
  
  exec { 'chown-vagrant-hdfs':
    command => 'sudo -u hdfs hadoop fs -chown vagrant /user/vagrant',
    require => Exec['vagrant-hdfs-dir']
  }
}