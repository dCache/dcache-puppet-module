#
# Class: dcache_operations::head_install
#
#   Sets up few dcache rpms
#
# === Parameters
#
#   from params.pp: $dcache_version, $jdk_version,  $postgres_version,
#
#
# === Authors
#
# Christian Voss
#

class dcache_operations::head_install {

  class {'repositories::postgresql':
    version =>  $dcache_operations::pg_repoversion,
    stage   =>  repositories,
  }
  
  swcollection::install { 'dcache::head' : } ->
  package { ["${::dcache_operations::basic_install::pg_prefix}-${dcache_operations::basic_install::pg_postfix}",
             "${::dcache_operations::basic_install::pg_prefix}-server-${dcache_operations::basic_install::pg_postfix}",
             "${::dcache_operations::basic_install::pg_prefix}-devel-${dcache_operations::basic_install::pg_postfix}",
             "${::dcache_operations::basic_install::pg_prefix}-docs-${dcache_operations::basic_install::pg_postfix}",
             "${::dcache_operations::basic_install::pg_prefix}-contrib-${dcache_operations::basic_install::pg_postfix}"] :
  } ->
    yumconfig::exclude {'postgres':
      packages => 'postgres*',
    }->
      file { '/var/log/pg_log' :
        ensure    => directory,
        owner     => 'postgres',
        group     => 'postgres',
        mode      => '0755',
      }

      class { '::dcache_operations::config::postgres' : }
      
}
