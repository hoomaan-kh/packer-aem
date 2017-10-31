include ::config::base

include aem_curator::install_java

if $::config::base::install_collectd {
  include aem_curator::install_collectd
}

include aem_curator::install_publish

if $::config::base::install_cloudwatchlogs {
  class { 'config::cloudwatchlogs':
    aem_role => 'publish',
  }
}
