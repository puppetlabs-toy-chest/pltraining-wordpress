class wordpress {
  File {
    owner => $httpd_user,
    group => $httpd_group,
    mode  => '0644',
  }

  case $::osfamily {
    'RedHat': {
       $httpd_user     = 'apache'
       $httpd_group    = 'apache'
       $httpd_pkg      = 'httpd'
       $httpd_svc      = 'httpd'
       $httpd_conf     = 'httpd.conf'
       $httpd_confdir  = '/etc/httpd/conf'
       $httpd_docroot  = '/var/www/html'
       $mysql_packages = [ 'mysql', 'mysql-server' ]
       $mysql_svc      = 'mysqld'
       $php_packages   = [ 'php', 'php-mysql', 'php-gd' ]
    }
    'Debian': {
       $httpd_user     = 'www-data'
       $httpd_group    = 'www-data'
       $httpd_pkg      = 'apache2'
       $httpd_svc      = 'apache2'
       $httpd_conf     = 'apache2.conf'
       $httpd_confdir  = '/etc/apache2'
       $httpd_docroot  = '/var/www'
       $mysql_packages = [ 'mysql-client', 'mysql-server' ]
       $mysql_svc      = 'mysql'
       $php_packages   = [ 'php5', 'libapache2-mod-php5' ]
    }
    default: {
      fail("Module ${module_name} is not supported on ${::osfamily}")
    }
  }

  package { $mysql_packages:
    ensure => present,
  }

  package { $php_packages:
    ensure => present,
  }

  package { $httpd_pkg:
    ensure => present,
  }

  file { $httpd_conf:
    ensure  => file,
    path    => "${httpd_confdir}/${httpd_conf}",
    owner   => 'root',
    group   => 'root',
    source  => "puppet:///modules/wordpress/${httpd_conf}",
    require => Package[$httpd_pkg],
  }

  file { $httpd_docroot:
    ensure => directory,
  }

  file { "${httpd_docroot}/wp-config.php":
    ensure => file,
    source => 'puppet:///modules/wordpress/wp-config.php',
  }

  service { $httpd_svc:
    ensure    => running,
    subscribe => File[$httpd_conf],
  }

  service { $mysql_svc:
    ensure    => running,
    subscribe => Package['mysql-server'],
  }

  exec { 'download wordpress':
    onlyif  => '/usr/bin/curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz',
    command => "/bin/tar -xvf /tmp/wordpress.tar.gz -C ${httpd_docroot} --strip-components=1",
    creates => "${httpd_docroot}/index.php",
    require => Package[$httpd_pkg],
  }

  exec { 'create wordpress database':
    command     => '/usr/bin/mysqladmin create wordpress',
    refreshonly => true,
    require     => Service[$mysql_svc],
    subscribe   => Package[$mysql_packages],
  }

  exec { 'set mysql root password':
    command     => '/usr/bin/mysqladmin -u root password "supersekrit"',
    refreshonly => true,
    subscribe   => Exec['create wordpress database'],
  }

}
