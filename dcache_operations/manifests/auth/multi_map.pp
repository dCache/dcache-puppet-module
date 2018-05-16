# == Class: dcache::auth::multi_map
#
#   Sets up the /etc/grid-security/storage-authzdb file
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
class dcache_operations::auth::multi_map ( $multi_map = undef ) {

  if $multi_map {
    file { 'multi_map_puppet' :
      path    => "/etc/dcache/multi-mapfile.puppet",
      owner  => 'root',
      group  => 'root',
      content => template('dcache_operations/multi-map.erb'),
      backup  => ".backup",
      } ~>
      exec {'multi_map_production':
        command => "/usr/bin/cp /etc/dcache/multi-mapfile.puppet /etc/dcache/multi-mapfile",
        creates => "/etc/dcache/multi-mapfile"
      }
  }
}
