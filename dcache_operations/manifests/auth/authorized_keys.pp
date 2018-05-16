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

class dcache_operations::auth::authorized_keys ( $authorized_keys = undef) {

  if ( $authorized_keys ){
    file { '/etc/dcache/admin/authorized_keys2' :
      content => template('dcache_operations/authorized_keys.erb'),
      backup  => ".backup",
      } ~>
      exec {'production-ssh-user-keys':
        command => "/usr/bin/cp /etc/dcache/admin/authorized_keys2.puppet /etc/dcache/admin/authorized_keys2",
        creates => "/etc/dcache/admin/authorized_keys2"
      }
  }

}
