# @summary
#  This class manages the bareos webui service, package and configuration, it will be automatically included when a resource is defined.
#
# @param manage_service
# @param manage_package
# @param package_name
# @param package_ensure
# @param service_name
# @param service_ensure
# @param service_enable
# @param config_dir
# @param manage_local_dir
# @param session_timeout
# @param pagination_values
# @param pagination_default_value
# @param save_previous_state
# @param label_pooltype
# @param theme
# @param directors
#
class bareos::webui (
  $manage_service = $bareos::manage_service,
  $manage_package = $bareos::manage_package,
  $package_name   = $bareos::webui_package_name,
  $package_ensure = $bareos::package_ensure,
  $service_name   = $bareos::webui_service_name,
  $service_ensure = $bareos::service_ensure,
  $service_enable = $bareos::service_enable,
  $config_dir     = $bareos::config_dir_webui,

  $manage_local_dir = true, # setup local bareos director
  $session_timeout = 3600,
  $pagination_values = '10,25,50,100',
  $pagination_default_value = 25,
  $save_previous_state = false,
  $label_pooltype = '',
  $theme = 'default',
  $directors = {},
) inherits bareos {
  if $manage_package {
    package { $package_name:
      ensure => $package_ensure,
      tag    => ['bareos', 'bareos_webui'],
    }
  }

  if $manage_service {
    service { $service_name:
      ensure => $service_ensure,
      enable => $service_enable,
      tag    => ['bareos', 'bareos_webui'],
    }
  }

  # directories
  file { $config_dir:
    ensure  => directory,
    purge   => true,
    recurse => true,
    force   => true,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package[$package_name],
    tag     => ['bareos', 'bareos_webui'],
  }

  file { "${bareos::webui::config_dir}/configuration.ini":
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('bareos/webui_configuration.erb'),
    notify  => Service[$bareos::webui::service_name],
    tag     => ['bareos', 'bareos_webui'],
  }

  concat { "${bareos::webui::config_dir}/directors.ini":
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    tag    => ['bareos', 'bareos_webui'],
  }

  if $manage_local_dir {
    bareos::webui::director { 'localhost':
      dir_address => 'localhost',
    }
  }

  create_resources(bareos::webui::director, $directors)
}
