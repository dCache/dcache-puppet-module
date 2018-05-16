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
class dcache_operations::config::postgres {

  $pg_data_dir = "/var/lib/pgsql/${::dcache_operations::pg_repoversion}/data"

  $postgres_conf = hiera_hash('dcache::postgres::postgres_conf',undef)
  $pg_hba_conf   = hiera_hash('dcache::postgres::pg_hba_conf',undef)
  $master_server = hiera('dcache::postgres::master_server',undef)
  
  $pg_user       = 'postgres'
  
  if $postgres_conf {
    file { 'postgres_conf_puppet' :
      path    => "${pg_data_dir}/postgresql.conf.puppet",
      owner  => 'postgres',
      group  => 'postgres',
      content => template('dcache_operations/postgres.conf.erb'),
      backup  => ".backup",
    } ~>
      exec {'postgres_conf_production':
        command => "/usr/bin/cp ${pg_data_dir}/postgresql.conf.puppet ${pg_data_dir}/postgresql.conf",
        creates => "${pg_data_dir}/postgresql.conf"
      }
  }

  if $pg_hba_conf {
    file { 'pg_hba_conf' :
      path    => "${pg_data_dir}/pg_hba.conf.puppet",
      owner  => 'postgres',
      group  => 'postgres',
      content => template('dcache_operations/pg_hba.conf.erb'),
      backup  => ".backup",
    } ~>
      exec {'pg_hba_conf_production':
        command => "/usr/bin/cp ${pg_data_dir}/pg_hba.conf.puppet ${pg_data_dir}/pg_hba.conf",
        creates => "${pg_data_dir}/pg_hba.conf"
      }
  }

  if $postgres_conf {

    file { 'archive_dir' :
      path    => "${pg_data_dir}/archive/",
      owner  => 'postgres',
      group  => 'postgres',
      ensure => 'directory',
    }

    if has_key($postgres_conf, 'replica') {
      if $postgres_conf['replica']['archive_mode'] == 'on' {
        file { 'no_recovery_conf' :
          path   => "${pg_data_dir}/recovery.conf",
          ensure => absent,
        }
        file {'/postgres-wal-archive':
          ensure => directory,
          owner  => 'postgres',
          group  => 'postgres',
        }
        file {'/root/bin/clear_wal_dir':
          owner  => 'root',
          group  => 'root',
          ensure => 'present',
          mode   => '0744',
          source => 'puppet:///modules/dcache_operations/root/bin/clear_wal_dir',
        }

        $clear_mailto       = hiera("dcache::cron::mailto","dot-ops@desy.de")
        $clear_wal_instance = upcase( $::hg_dot::head::dcache_instance )
        $clear_pg_version   = "${::dcache_operations::pg_repoversion}"
        $clear_mod_time     = hiera('dcache::cron::clear_wal_modification_time',600)

        cron { 'database backup':
          command     => "/root/bin/clear_wal_dir ${clear_wal_instance} ${clear_pg_version} >/tmp/clear_wal_dir.${::hg_dot::head::dcache_instance}",
          user        => 'root',
          minute      => hiera("dcache::cron::backup_wal_minute","0"),
          hour        => hiera("dcache::cron::backup_wal_hour","0"),
          monthday    => hiera("dcache::cron::backup_wal_monthday","*"),
          month       => hiera("dcache::cron::backup_wal_month","*"),
          weekday     => hiera("dcache::cron::backup_wal_weekday","*"),
          environment => "MAILTO=${clear_mailto}",
        }
        
        cron { 'clear archive':
          command     => "find ${pg_data_dir}/archive/ -mindepth 0 -maxdepth 1 -mmin +${clear_mod_time} -type f  -exec rm {} \;",
          user        => 'root',
          minute      => hiera("dcache::cron::clear_wal_minute","0"),
          hour        => hiera("dcache::cron::clear_wal_hour","0"),
          monthday    => hiera("dcache::cron::clear_wal_monthday","*"),
          month       => hiera("dcache::cron::clear_wal_month","*"),
          weekday     => hiera("dcache::cron::clear_wal_weekday","*"),
          environment => "MAILTO=${clear_mailto}",
        }
      }
    }
    
    if has_key($postgres_conf, 'replica') {
      if $postgres_conf['replica']['hot_standby'] == 'on' {
        
        file { 'recovery_conf' :
          path    => "${pg_data_dir}/recovery.conf.puppet",
          owner  => 'postgres',
          group  => 'postgres',
          content => template('dcache_operations/recovery.conf.erb'),
          backup  => ".backup",
          } ~>
          exec {'recovery_conf_production':
            command => "/usr/bin/cp ${pg_data_dir}/recovery.conf.puppet ${pg_data_dir}/recovery.conf",
            creates => "${pg_data_dir}/recovery.conf"
          }
      }
    }
  }
}
