name             'nephology'
maintainer       'Jordan Tardif'
maintainer_email 'jordan@dreamhost.com'
license          'All rights reserved'
description      'Installs/Configures Nepholigy'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "cpan"
depends "git"
depends "nginx"
depends "runit"
depends "build-essential"
depends "mysql2_chef_gem"
depends "database", "=4.0.7"
depends "mysql"
depends "tftp"
depends "dhcp"
