name             'gitlab'
maintainer       'Zühlke Engineering GmbH'
maintainer_email 'bvo@zuehlke.com'
license          'All rights reserved'
description      'Installs/Configures gitlab'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.3'

#
# direct dependencies
#
depends 'apt', '2.0.0'
depends 'mysql', '3.0.2'
depends 'postgresql', '3.0.2'
depends 'vagrant-ohai', '1.0.0'
depends 'database', '1.4.0'
depends 'postfix', '2.1.6'
depends 'vagrant', '0.2.0'

#
# transitive, berkshelf-managed dependencies
#
depends 'aws', '0.101.2'
depends 'build-essential', '1.4.0'
depends 'openssl', '1.0.2'
depends 'xfs', '1.1.0'