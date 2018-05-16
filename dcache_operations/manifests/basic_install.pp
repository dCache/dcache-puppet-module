#
# Class: dcache_operations::basic_install
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
# Christian Voss, initially Sven Sternberger
#
class dcache_operations::basic_install (
  $dcache_version=undef,
  $pg_repoversion=undef,
  $postgres_version=undef,
  $jdk_version=undef,
){

  #Filter depending on dcache instance (for revised puppet module change encgroup 2->3)
  $pg_prefix=regsubst($pg_repoversion,'^(\d+)\.{0,1}(\d+)$','postgresql\1\2')

  $pg_postfix=$postgres_version

  swcollection::install { 'dcache::common' : }
  #-----------dcache, jdk -----------------------
  package {'dcache': ensure => $dcache_version,}

  if $jdk_version != 'openjdk' {
    
    if $jdk_version.match('^[a-z]{3}'){
      notify { "Use pre Centos-7.4 java package naming scheme" : }
      package {'jdk'   : name   => $jdk_version,}   
      yumconfig::exclude {'dcache':
        packages => 'dcache jdk*',
        require  => [ Package['dcache'], Package['jdk'] ]
      }
    }
    else {
      notify { "Use Centos-7.4 and newer java package naming scheme" : }
      package {'jdk1.8'   : ensure   => $jdk_version,}
      yumconfig::exclude {'dcache':
        packages => 'dcache jdk*',
        require  => [ Package['dcache'], Package['jdk1.8'] ]    
      }
    }
  }

  if $jdk_version == 'openjdk' {
    yumconfig::exclude {'dcache':
      packages => 'dcache *jdk*',
      require  => [ Package['dcache'], Package['java-1.8.0-openjdk'] ]    
    }
  }
}

