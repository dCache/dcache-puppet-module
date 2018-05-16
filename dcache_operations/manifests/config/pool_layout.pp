# == Class: dcache::config::dcache_conf
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

class dcache_operations::config::pool_layout ($dcache_layout){
  $layout_hash        = $dcache_layout
  $pool_layout_hash   = $::pools
  $pool_config        = hiera_hash('dcache::pool_list',undef)
  $nfs_port           = hiera('dcache::basic_nfs_port',undef)

  if has_key($pool_config, $hostname) {
    $partner          = $pool_config[$hostname]['partner']
    $hsm_pools        = $pool_config[$hostname]['hsmpools']
    $rot_pools        = $pool_config[$hostname]['rotating']
  }
  else {
    $partner          = 'NONE'
  }

  $pool_gap           = hiera('dcache::pool_gap',214748364800)
  $do_scrub           = hiera('dcache::activate_scrub',true)
  $scrub_intervall    = hiera('dcache::scrub_intervall',336)
  $breackeven_factor  = hiera('dcache::breackeven_factor',0.7)
  $cost_factor        = hiera('dcache::cost_factor',0.5)

  $rh_timeout         = hiera('dcache::rh_timeout',28800)
  $st_timeout         = hiera('dcache::st_timeout',28800)
  $rm_timeout         = hiera('dcache::rm_timeout',28800)


  if $pool_layout_hash{
    unless str2bool($::puppetfirstrun) {
      file { 'pool-layout' :
        path    => "/etc/dcache/layouts/$hostname.conf.puppet",
        content => template('dcache_operations/pool.layout.conf.erb'),
        backup  => ".backup",
        } ~>
        exec {'production-layout':
          command => "/bin/cp /etc/dcache/layouts/$hostname.conf.puppet /etc/dcache/layouts/$hostname.conf",
          creates => "/etc/dcache/layouts/$hostname.conf"
        }
    }
  }

  if $pool_layout_hash {
    file { 'pool-setup-all' :
      path    => "/etc/dcache/all.pools.setup.xml",
      content => template('dcache_operations/pool.setup.conf.erb'),
    }
    file { '/root/distribute_setups.py' :
      source => 'puppet:///modules/dcache_operations/root/distribute_setups.py',
    }
  }
}
