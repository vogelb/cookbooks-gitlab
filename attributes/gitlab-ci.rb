node.default['gitlab_ci']['gitlab_ci_packages'] = %w{ wget curl gcc checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libreadline6-dev libc6-dev libssl-dev libmysql++-dev make build-essential zlib1g-dev openssh-server git-core libyaml-dev postfix libpq-dev libicu-dev redis-server }
node.default['gitlab_ci']['user'] = 'git'
node.default['gitlab_ci']['password'] = 'gitlab'