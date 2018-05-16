# == Class: dcache::config::nfs_exports
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
class dcache_operations::config::nfs_exports ( $nfs_exports = undef ){

  if ( $nfs_exports ){
    file { '/etc/exports.puppet' :
      content => template('dcache_operations/nfs.exports.erb'),
      backup  => ".backup",
      } ~>
      exec {'production-exports':
        command => "/usr/bin/cp /etc/exports.puppet /etc/exports",
        creates => "/etc/exports"
      }
  }
  
}
