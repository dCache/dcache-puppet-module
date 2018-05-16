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
class dcache_operations::config::resilience_monitoring {
  
  $resilient_options   = hiera_hash('dcache::resilient_options',undef)
  $dcache_installation = hiera('dcache::dcache_instance',undef)

  #Define notification address
  if has_key($resilient_options, 'resilient_pgroup') {
    $check_mailto = $resilient_options['mailto']
  }
  else {
    $check_mailto = "dot-ops@desy.de"
  }
  #Define Resilient Pool Groups
  if has_key($resilient_options, 'resilient_pgroup') {
    $pgroup  = $resilient_options['resilient_pgroup']
  }
  #Define database host - default dcache-dir-<instance_name>
  if has_key($resilient_options, 'db_host') {
    $db_host = $resilient_options['db_host']
  }
  else {
    $db_host = "dcache-dir-${dcache_installation}"
    }
  #Define webadmin host - default dcache-se-<instance_name>
  if has_key($resilient_options, 'webadmin_host') {
    $webadmin_host = $resilient_options['webadmin_host']
  }
  else {
    $webadmin_host = "dcache-se-${dcache_installation}"
  }
  #Define postgres user - default postgres
  if has_key($resilient_options, 'db_user') {
    $postgres_user = $resilient_options['db_user']
  }
  else {
    $postgres_user = "postgres"
  }

  #Setup check script and cronjob

  file { '/root/bin/resilience_check.sh' :
    content => template('dcache_operations/resilience_check.erb'),
    backup  => ".backup",
    mode    => '0744',
    require => File['/root/bin']
  }
  
  cron { 'Check for Resilient Status':
    command     => "/root/bin/resilience_check.sh",
    user        => 'root',
    minute      => "0",
    environment => "MAILTO=${check_mailto}",
  }
}
