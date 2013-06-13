# Attributes for the gitlab recipe

# Gitlab user and home
node.default['gitlab']['user'] = 'git'
node.default['gitlab']['home'] = "/home/#{node['gitlab']['user']}/gitlab"

# Dependencies
node.default['gitlab']['packages'] = %w{ build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl git-core openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev python }
