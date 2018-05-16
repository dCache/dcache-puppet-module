# == Class: dcache::config::global
#
#   Sets up the dcache global config files
#
# === Parameters
#
#   Nothing.
#
#
# === Authors
#
# Sven Sternberger, Christian Voss
#
class dcache_operations::config::global ( $jdk_version=undef ) {

  # environment java variables

  if $jdk_version != 'openjdk' {
    file {'/etc/profile.d/java.sh':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => 'puppet:///modules/dcache_operations/etc/profile.d/java.sh',
    }
    augeas {'set_security_java':
      context  => '/files/usr/java/default/jre/lib/security/java.security',
      changes  => [
                   'set jdk.certpath.disabledAlgorithms MD2',
                   ],
      incl     => '/usr/java/default/jre/lib/security/java.security',
      lens     => 'Properties.lns',
      # require  => Package['jdk'],
    }
  }
  

  if $jdk_version == 'openjdk' {
    file {'/etc/profile.d/java.sh':
      ensure  => absent,
    }
  }  
  
  class { '::tuned':
    profile => "dcache_$::dcache_operations::dcache_nodetype",
    source  => "puppet:///modules/dcache_operations/etc/tune-profiles/dcache_$::dcache_operations::dcache_nodetype",
  }

  #logrotate
  file {'logrotate_dcache':
    ensure => present,
    path   => '/etc/logrotate.d/dcache',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/dcache_operations/etc/logrotate.d/dcache',
  }

  # sudo rights for needed for nrpe check_zfs
  if $zfs_version {
    file { '/etc/sudoers.d/nrpe-zfs':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      source  => 'puppet:///modules/dcache_operations/etc/sudoers.d/nrpe-zfs',
    }
  }

}
