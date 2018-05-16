# == Class: dcache::auth::gss
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

class dcache_operations::auth::gss (
  $gss_conf = undef,
){

  $gss_layout = $gss_conf
  
  file { 'gss_puppet' :
    path    => '/etc/dcache/gss.conf.puppet',
    content => template('dcache_operations/gss.conf.erb'),
    backup  => ".backup",
    } ~>
    exec {'gss_production':
      command => "/usr/bin/cp /etc/dcache/gss.conf.puppet /etc/dcache/gss.conf",
      creates => "/etc/dcache/gss.conf"
    }

}
