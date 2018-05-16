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

class dcache_operations::auth::admin_acl ( $authorized_keys = undef) {

  if ( $authorized_keys ){
    file { '/etc/dcache/admin/users/acls/*.*.*' :
      content => template('dcache_operations/acl.admin.erb'),
      backup  => ".backup",
      } ~>
      exec {'production-ssh-user-acls':
        command => "/usr/bin/cp /etc/dcache/admin/users/acls/*.*.*.puppet /etc/dcache/admin/users/acls/*.*.*",
        creates => "/etc/dcache/admin/users/acls/*.*.*"
      }
  }

}
