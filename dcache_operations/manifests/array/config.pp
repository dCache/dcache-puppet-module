# PRIVATE CLASS: Do not call directly
class dcache_operations::array::config {

  customfact::set { 'array_type'    : value => $::dcache_operations::pool_install::array_type }
  customfact::set { 'array_partner' : value => $::dcache_operations::pool_install::array_partner }

  yumconfig::exclude {'sm':
    packages => 'SMclient SMagent SMruntime SMutil SMesm',
  }

  file { '/etc/multipath.conf':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => [
      "puppet:///modules/dcache_operations/etc/multipath.${array_type}.conf",
      'puppet:///modules/dcache_operations/etc/multipath.conf',
    ],
  }

  file { '/root/arraycfg' :
    ensure  => 'directory',
    source  => 'puppet:///modules/dcache_operations/root/arraycfg',
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    recurse => 'remote',
  }

  file { '/etc/sudoers.d/nrpe-mpath':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/dcache_operations/etc/sudoers.d/nrpe-mpath',
  }
  nrpe::plugin { 'check_multipath' :
    plugin  => 'check_multipath.pl',
    args    => '-s -l REG -o "$ARG1$" -m "$ARG2$"',
  }
  
  case $::dcache_operations::pool_install::array_type {
    'md3260','md3460': {
      file { '/usr/sbin/sm-getprofile.py':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0775',
        source  => 'puppet:///modules/dcache_operations/usr/sbin/sm-getprofile.py',
      }
      
      # Setup cronjob with mv to prevent an empty file while running
      cron {'cronjob-sm-getprofile':
        ensure  => present,
        command => 'FILE=$(mktemp); /usr/sbin/sm-getprofile.py > $FILE; mv -f $FILE /var/tmp/sm-getprofile.tmp; chmod +r /var/tmp/sm-getprofile.tmp',
        hour    => '*/2',
        minute  => '0',
      }
    }
    'netapp': {
      file { '/usr/sbin/sm-getprofile.py':
              ensure  => present,
              owner   => 'root',
              group   => 'root',
              mode    => '0775',
              source  => 'puppet:///modules/dcache_operations/usr/sbin/sm-getprofile.py',
            }
            
            # Setup cronjob with mv to prevent an empty file while running
            cron {'cronjob-sm-getprofile':
              ensure  => present,
              command => 'FILE=$(mktemp); /usr/sbin/sm-getprofile.py > $FILE; mv -f $FILE /var/tmp/sm-getprofile.tmp; chmod +r /var/tmp/sm-getprofile.tmp',
              hour    => '*/2',
              minute  => '0',
            }
    }
  }
    
  # remove legacy stuff
  customfact::set { 'md3xxx' : ensure => absent, value => $array_type }
  file { '/root/md3xxx' : ensure      => absent, force => true }
  file { '/usr/share/dcache/sm-getprofile.py' : ensure => absent, force => true }
}
