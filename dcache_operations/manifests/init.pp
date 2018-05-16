# == Class: dcache_operations::init
#
#   Sets up dCache components
#
# === Parameters
#
# from params.pp
#
# === Authors
#
# Christian Voss <christian.voss@desy.de>
#
class dcache_operations (
  $dcache_version=undef,
  $pg_repoversion=undef,
  $postgres_version=undef,
  $jdk_version=undef,
  $array_type=undef,
  $dcache_conf=undef,
  $dcache_layout=undef,
  $dcache_nodetype=undef,
  $gplazma_conf=undef,
  $nfs_exports=undef,
  $authorized_keys=undef,
  $ha_mode=undef,
  $storage_authzdb=undef,
  $multi_map=undef,
  $gss_conf=undef,
){

  file {'/root/.screenrc':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/dcache_operations/root/.screenrc',
    require => Package['screen'],
  }
  
  class {'::dcache_operations::basic_install':
    dcache_version   => $dcache_version,
    pg_repoversion   => $pg_repoversion,
    postgres_version => $postgres_version,
    jdk_version      => $jdk_version,
  }

  case $dcache_nodetype {
    'head','dir','se','core','billing','ha_head' : {
      class{ '::dcache_operations::head_install' :}
    }
    'door' : {
      class{ '::dcache_operations::door_install' :}
    }
    'pool' : {
      class{ '::dcache_operations::pool_install' :}
    }
  }
   
  class {'::dcache_operations::config::global':
    jdk_version => $jdk_version,
  }

  class {'::dcache_operations::config::dcache_conf':
    dcache_conf => $dcache_conf
  }

  if ( $dcache_nodetype == 'pool' ){
    class {'::dcache_operations::config::pool_layout':
      dcache_layout => $dcache_layout
    }
  }
  else {
    if ( $dcache_layout ) {
      class {'::dcache_operations::config::dcache_layout':
        dcache_layout => $dcache_layout,
        ha_mode       => $ha_mode
      }
    }
  }

  if ( $dcache_layout ){
    if has_key($dcache_layout, 'domains'){
      if has_key($dcache_layout['domains'], 'gplazmaDomain' ){
        class {'::dcache_operations::auth::gplazma':
          gplazma_conf => $gplazma_conf,
          multi_map => $multi_map
        }
        class {'::dcache_operations::auth::storage_authzdb' :
          storage_authzdb => $storage_authzdb
        }
        class {'dcache_operations::auth::gss' :
          gss_conf => $gss_conf
        }
        include dcache_operations::auth::grid_vrolemap
      }
      if has_key($dcache_layout['domains'], 'k5dcapDomain' ){
        class {'dcache_operations::auth::gss' :
          gss_conf => $gss_conf
        }
      }
    }
  }
  
  if ( $dcache_layout ){
    if has_key($dcache_layout, 'domains'){
      $domains = $dcache_layout['domains']
      $domains.each |$name, $cells| {
        $cells.each |$name, $options| {
          if $name == "poolmanager"{
            notify { 'Configure ssh keys and acl' : }
            class {'::dcache_operations::auth::authorized_keys':
              authorized_keys => $authorized_keys
            }
            class {'::dcache_operations::auth::admin_acl':
              authorized_keys => $authorized_keys
            }
          }
        }
      }
    }
  }
  
  if ( $nfs_exports ){
    class {'::dcache_operations::config::nfs_exports':
      nfs_exports => $nfs_exports
    }
  }

  if ( $dcache_layout ){
    if has_key($dcache_layout, 'domains'){
      if has_key($dcache_layout['domains'], 'resilientDomain' ){
        class {'::dcache_operations::config::resilience_monitoring': }
      }
    }
  }
}
