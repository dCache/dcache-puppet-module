# == Class: dcache::auth::gplazma
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
class dcache_operations::auth::gplazma (
  $gplazma_conf = undef,
  $multi_map    = undef
){

  file { 'gplazma_puppet' :
    path    => '/etc/dcache/gplazma.conf.puppet',
    content => template('dcache_operations/gplazma.conf.erb'),
    backup  => ".backup",
    } ~>
    exec {'gplazma_production':
      command => "/usr/bin/cp /etc/dcache/gplazma.conf.puppet /etc/dcache/gplazma.conf",
      creates => "/etc/dcache/gplazma.conf"
    }
    
    $gplazma_conf.each |$method| {
      if is_hash( $method ) {
        if has_key( $method, 'map'){
          $method.each |$plugin_list| {
            $plugin_list.each |$plugin_def| {
              if is_array ($plugin_def){
                $plugin_def.each |$plugin|{
                  if has_key( $plugin, 'multimap' ) {
                    notify { "Configuring multi-map plugin": }
                    class { '::dcache_operations::auth::multi_map' :
                      multi_map => $multi_map
                    }
                  }
                }
              }
            }
          }
        }
      }
    }  
}
