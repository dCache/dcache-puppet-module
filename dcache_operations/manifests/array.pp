# == Class: dcache::array
#
#   Setup dCache md3260/3460/... storage arrays
#
# === Authors
#
# Jan Engels <jan.engels@desy.de>
#
class dcache_operations::array {

    case $::dcache_operations::pool_install::array_type {

      'md3260','md3460': {
        class { 'repositories::dell_powervault' :
          before => Class['dcache_operations::array::install'],
        }
      }

      'netapp': {
        class { 'repositories::netapp' :
          before => Class['dcache_operations::array::install'],
        }
      }
    }

    anchor {'dcache_operations::array::begin': } ->
    class { dcache_operations::array::install : } ->
    class { dcache_operations::array::config : } -> # ~> not used explicitely!
    class { dcache_operations::array::service : } ->
    anchor {'dcache_operations::array::end': }
}
