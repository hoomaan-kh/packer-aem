class { 'config::base':
  before => [
    Class['config::certs'],
    Class['Aem_curator::Install_dispatcher']
  ]
}

class { 'config::certs':
  require => [
    Class['config::base']
  ],
  before  => [
    Class['Aem_curator::Install_dispatcher']
  ]
}

include aem_curator::install_dispatcher

if $::config::base::install_cloudwatchlogs {

  if $::config::base::install_cloudwatchlogs_httpd {
    config::cloudwatchlogs_httpd { 'Setup CloudWatch for Dispatcher': }
  }

  # At the end of doing all Cloudwatch actions we are disabling and stopping the
  # CloudWatch agent, and removing the awslogs pid file.
  # Related to https://github.com/shinesolutions/packer-aem/issues/192
  exec { 'Disable Cloudwatchlogs agent':
    command => "systemctl disable ${::config::base::awslogs_service_name}",
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    before  => Exec['Stop Cloudwatchlogs agent'],
    require => Service[$::config::base::awslogs_service_name],
  } -> exec { 'Stop Cloudwatchlogs agent':
    command => "systemctl stop ${::config::base::awslogs_service_name}",
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    before  => File["${::config::base::awslogs_path}/state/awslogs.pid"],
    require => Exec['Disable Cloudwatchlogs agent'],
  } -> file {"${::config::base::awslogs_path}/state/awslogs.pid":
    ensure  => absent,
    require => Exec['Stop Cloudwatchlogs agent']
  }
}

if $::config::base::install_cloudwatch_metric_agent {
  config::cloudwatch_metric_agent { 'Setup Cloudwatch Metric Agent for Dispatcher':
  disk_path   => [
    $::config::base::metric_root_disk_path,
    $::config::base::metric_data_disk_path
  ],
  }
}
