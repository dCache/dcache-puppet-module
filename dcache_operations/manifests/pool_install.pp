#
# Class: dcache_operations::pool_install
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

class dcache_operations::pool_install {

  swcollection::install { 'dcache::pool' : }

  if ( hiera('dcache::enable_wlcg',false) ){
    class {'repositories::wlcg':
      stage => repositories,
    }
  }

  $pool_config   = hiera_hash('dcache::pool_list',undef)

  if has_key($pool_config, $hostname) {
    $array_type    = $pool_config[$hostname]['model']
    $array_partner = $pool_config[$hostname]['partner']

    notify { "dcache array type: ${array_type}" : }

    case $array_type {
      'md3260','md3460': { include dcache_operations::array }
      'netapp':          { include dcache_operations::array }
      default:           {}
    }
  }
  
  file {"/etc/cron.daily/mlocate":
    ensure => absent,
  }
  file {'/usr/local/bin/osm-hsmcp.py':
    ensure  => absent,
  }
  file {'/usr/share/dcache/lib/osm-hsmcp.py':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/dcache_operations/usr/share/dcache/lib/osm-hsmcp.py',
  }
  file {'/etc/osm':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    } ->
    file {'/etc/osm/sld.host':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "osmsl\n",
    }

}
