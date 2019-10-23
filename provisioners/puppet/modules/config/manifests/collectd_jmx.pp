define config::collectd_jmx (
  $jdk_version = lookup('aem_curator::install_java::jdk_version'),
  $jdk_version_update = lookup('aem_curator::install_java::jdk_version_update'),
) {

  # collectd::plugin::genericjmx also installs collectd-java plugin, which in
  # turn also installs openjdk and makes it a default alternative, hence we need
  # to set the default back to Oracle JDK
  class { 'collectd::plugin::genericjmx':
    manage_package => true,
  } -> exec { "alternatives --set java /usr/java/jdk1.${jdk_version}.0_${jdk_version_update}/jre/bin/java":
    path => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
  }

}
