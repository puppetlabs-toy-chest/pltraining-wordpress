require 'spec_helper'


describe "wordpress" do
  let(:node) { 'test.example.com' }

  context "on RedHat" do
    let(:facts) { {
      :osfamily => 'RedHat',
    } }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_package('mysql-server') }
    it { is_expected.to contain_package('mysql') }
    it { is_expected.to contain_package('httpd') }
    it { is_expected.to contain_package('php') }
    it { is_expected.to contain_package('php-mysql') }
    it { is_expected.to contain_package('php-gd') }
    it { is_expected.to contain_service('mysqld') }
    it {
      is_expected.to contain_file('httpd.conf').with({
        'ensure'  => 'file',
        'path'    => '/etc/httpd/conf/httpd.conf',
        'source'  => 'puppet:///modules/wordpress/httpd.conf',
        'require' => 'Package[httpd]',
      })
    }
    it { is_expected.to contain_file('/var/www/html') }
    it { is_expected.to contain_file('/var/www/html/wp-config.php') }
    it {
      is_expected.to contain_exec("download wordpress")
        .with({
          'onlyif'  => '/usr/bin/curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz',
          'command' => '/bin/tar -xvf /tmp/wordpress.tar.gz -C /var/www/html --strip-components=1',
          'creates' => '/var/www/html/index.php',
          'require' => 'Package[httpd]',
      })
    }
    it {
      is_expected.to contain_exec("create wordpress database")
        .with({
          'command'     => '/usr/bin/mysqladmin create wordpress',
          'refreshonly' => true,
          'require'     => 'Service[mysqld]',
      }).that_subscribes_to('Package[mysql-server]')
    }
    it {
      is_expected.to contain_exec("create wordpress database")
        .with({
          'command'     => '/usr/bin/mysqladmin create wordpress',
          'refreshonly' => true,
          'require'     => 'Service[mysqld]',
      }).that_subscribes_to('Package[mysql]')
    }
    it {
      is_expected.to contain_exec("set mysql root password")
        .with({
          "command"     => "/usr/bin/mysqladmin -u root password \"supersekrit\"",
          "refreshonly" => true,
          "subscribe"   => "Exec[create wordpress database]",
      })
    }
  end

  context "on Debian" do
    let(:facts) { {
      :osfamily => 'Debian',
    } }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_package('mysql-server') }
    it { is_expected.to contain_package('mysql-client') }
    it { is_expected.to contain_package('apache2') }
    it { is_expected.to contain_package('php5') }
    it { is_expected.to contain_package('libapache2-mod-php5') }
    it { is_expected.to contain_service('mysql') }
    it {
      is_expected.to contain_file('apache2.conf').with({
        'ensure'  => 'file',
        'path'    => '/etc/apache2/apache2.conf',
        'source'  => 'puppet:///modules/wordpress/apache2.conf',
        'require' => 'Package[apache2]',
      })
    }
    it { is_expected.to contain_file('/var/www') }
    it { is_expected.to contain_file('/var/www/wp-config.php') }
    it {
      is_expected.to contain_exec("download wordpress")
        .with({
          'onlyif'  => '/usr/bin/curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz',
          'command' => '/bin/tar -xvf /tmp/wordpress.tar.gz -C /var/www --strip-components=1',
          'creates' => '/var/www/index.php',
          'require' => 'Package[apache2]',
      })
    }
    it {
      is_expected.to contain_exec("create wordpress database")
        .with({
          'command'     => '/usr/bin/mysqladmin create wordpress',
          'refreshonly' => true,
          'require'     => 'Service[mysql]',
      }).that_subscribes_to('Package[mysql-server]')
    }
    it {
      is_expected.to contain_exec("create wordpress database")
        .with({
          'command'     => '/usr/bin/mysqladmin create wordpress',
          'refreshonly' => true,
          'require'     => 'Service[mysql]',
      }).that_subscribes_to('Package[mysql-client]')
    }
    it {
      is_expected.to contain_exec("set mysql root password")
        .with({
          "command"     => "/usr/bin/mysqladmin -u root password \"supersekrit\"",
          "refreshonly" => true,
          "subscribe"   => "Exec[create wordpress database]",
      })
    }
  end

  context "on Windows" do
    let(:facts) { {
        :osfamily => 'Windows',
    } }

    it { is_expected.to raise_error(Puppet::Error) }
  end

end

