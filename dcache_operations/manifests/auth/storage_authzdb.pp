# == Class: dcache::auth::storage_authzdb
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
class dcache_operations::auth::storage_authzdb ( $storage_authzdb = undef ) {

  if $storage_authzdb {
    file { 'storage_authzdb_puppet' :
      path    => "/etc/grid-security/storage-authzdb.puppet",
      owner  => 'root',
      group  => 'root',
      content => template('dcache_operations/storage-authzdb.erb'),
      backup  => ".backup",
      } ~>
      exec {'storage_authzdb_production':
        command => "/usr/bin/cp /etc/grid-security/storage-authzdb.puppet /etc/grid-security/storage-authzdb",
        creates => "/etc/grid-security/storage-authzdb"
      }
  }
}
