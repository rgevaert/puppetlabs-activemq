# Class: activemq::packages
#
#   ActiveMQ Packages
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class activemq::packages (
  $version,
  $manage_user,
  $manage_home,
  $manage_init
) {

  validate_re($version, '^[._0-9a-zA-Z:-]+$')
  validate_bool($manage_user)
  validate_bool($manage_home)
  validate_bool($manage_init)

  $version_real = $version

  # Default behaviour is to manage user, group, and home
  # because package don't handle this.

  if($manage_user)
  {
    group { 'activemq':
      ensure => 'present',
      gid    => 92,
      before => User['activemq']
    }

    user { 'activemq':
      ensure  => 'present',
      comment => 'Apache Activemq',
      gid     => 92,
      home    => '/usr/share/activemq',
      shell   => '/bin/bash',
      uid     => 92,
      before  => Package['activemq'],
    }
  }

  if($manage_home){
    file { $home:
      ensure => directory,
      owner  => '0',
      group  => '0',
      mode   => '0755',
      before => Package['activemq'],
    }
  }
  

  package { 'activemq':
    ensure  => $version_real,
    notify  => Service['activemq'],
  }

  if($manage_init)
  {
    # JJM Fix the activemq init script always exiting with status 0
    # FIXME This should be corrected in the upstream packages
    file { '/etc/init.d/activemq':
      ensure  => file,
      path    => '/etc/init.d/activemq',
      content => template("${module_name}/init/activemq"),
      owner   => '0',
      group   => '0',
      mode    => '0755',
    }
  }

}
