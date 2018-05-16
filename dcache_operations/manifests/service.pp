# == Class: dcache_operations::service
#
#   Ensure dCache is running
#   Redhat Linux systems only!
#
# === Authors
#
# Contains code from dcache-puppet at github
#

class dcache_operations::service( $service_ensure = 'stopped' ) {

  case $service_ensure {
    'running' : {
      exec { "dcache start":
        command => "dcache start",
        path    => $::path,
        onlyif  => [
                    "test ; if dcache check-config | grep -q ERROR ; then false; else true ; fi",
                    "test ! -e /etc/dcache/halt.dcache",
                    ]
      }
    }
    'stopped' : {
        exec { 'dcache-stop':
          command     => "dcache stop",
          path        => $::path,
          before      => Exec['dcache-update_db'],
        }
    }
    default   : {
      fail("dCache service status must be running stopped ")
    }
  }
  

}
