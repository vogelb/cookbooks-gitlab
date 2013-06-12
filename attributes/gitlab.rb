node.default['gitlab']['packages'] = %w{ build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl git-core openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev python }
node.default['gitlab']['user'] = 'git'
node.default['gitlab']['password'] = 'gitlab'
