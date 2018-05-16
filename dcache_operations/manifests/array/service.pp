# PRIVATE CLASS: Do not call directly
class dcache_operations::array::service {
  service { 'multipathd' :
    #ensure    => running, # better keep this unmanaged...
    enable     => true,
    hasrestart => true,
  }

  #FIXME SMagent
}
