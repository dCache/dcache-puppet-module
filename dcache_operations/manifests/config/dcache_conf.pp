# == Class: dcache::config::dcache_conf
#
#   Sets up the dcache.conf file
#
# === Parameters
#
#   Nothing.
#
#
# === Authors
#
# Christian Voss
#
class dcache_operations::config::dcache_conf ($dcache_conf){

  $dcache_instance = hiera('dcache::dcache_instance')
    
  $dcache_zookeepers_1 = hiera("dcache::${dcache_instance}::zookeeper::server_name_1","localhost")
  $dcache_zookeepers_2 = hiera("dcache::${dcache_instance}::zookeeper::server_name_2","localhost")
  $dcache_zookeepers_3 = hiera("dcache::${dcache_instance}::zookeeper::server_name_3","localhost")

  file { '/etc/dcache/dcache.conf' :
    content => template('dcache_operations/dcache.conf.erb'),
    backup  => ".backup",
  }
  
  
}
