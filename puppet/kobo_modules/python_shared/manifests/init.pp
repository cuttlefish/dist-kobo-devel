class python_shared ($venv) {
  class { 'python_shared::install': } #->
  class { 'python_shared::config': } ->
  Class['python_shared']
}

class python_shared::install inherits python_shared {
  class { 'python':
    version => 'system',
    pip => true,
    dev => true,
    virtualenv => true,
    gunicorn => false,
  } ->
  python::pip { 'virtualenvwrapper':
    virtualenv => 'system',
    owner => 'root',
  }
}

class python_shared::config inherits python_shared {
  file { $venv['location']:
    ensure => directory,
    owner => 'vagrant',
    group => 'vagrant',
  }
  file { '/etc/profile.d/virtualenvwrapper.sh':
    ensure => file,
    content => 'export WORKON_HOME=~/.virtualenvs; source virtualenvwrapper.sh',
  }
}
