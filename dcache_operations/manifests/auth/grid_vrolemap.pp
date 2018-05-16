# == Class: dcache::auth::dcache_conf
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
class dcache_operations::auth::grid_vrolemap {

  $grid_vrolemap = hiera_hash('dcache::grid_vrolemap',undef)
  
  if $grid_vrolemap {
    file { 'grid_vrolemap_puppet' :
      path    => "/etc/grid-security/grid-vorolemap.puppet",
      owner  => 'root',
      group  => 'root',
      content => template('dcache_operations/grid.vrolemap.erb'),
      backup  => ".backup",
      } ~>
      exec {'grid_vrolemap_production':
        command => "/usr/bin/cp /etc/grid-security/grid-vorolemap.puppet /etc/grid-security/grid-vorolemap",
        creates => "/etc/grid-security/grid-vorolemap"
      }
  }
}
