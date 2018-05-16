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
class dcache_operations::config::dcache_layout ($dcache_layout, $ha_mode){
  $layout_hash = $dcache_layout
  $is_ha       = $ha_mode

  notify { "Configuring HA-Mode layout: ${is_ha}" : }

  file { 'layout' :
    path    => "/etc/dcache/layouts/$hostname.conf",
    content => template('dcache_operations/layout.conf.erb'),
    backup  => ".backup",
  }
  
  
}
