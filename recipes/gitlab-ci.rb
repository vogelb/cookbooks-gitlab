#
# Cookbook Name:: gitlab
# Recipe:: gitlab-ci
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

include_recipe "apt"
include_recipe "vagrant-ohai"

node.set['gitlab_ci']['home'] = "/home/#{node['gitlab_ci']['user']}/gitlab_ci"

# Install packages
node['gitlab_ci']['gitlab_ci_packages'].each do |base_package|
  package base_package do
    action :install
  end
end

include_recipe "gitlab::gitlab-commons"

# Create databases and users
%w{ gitlab_ci_production }.each do |db|
  mysql_database "#{db}" do
    connection node['mysql']['connection']
    action :create
  end
end

mysql_database_user 'gitlab_ci' do
  connection node['mysql']['connection']
  password 'gitlab_ci'
  action :create
end

# Grant all privelages on all databases/tables from localhost to vagrant
mysql_database_user 'gitlab_ci' do
  connection node['mysql']['connection']
  password node['gitlab_ci']['password']
  action :grant
end

# Checkout gitlab-ci
git 'get gitlab-ci' do
  user node['gitlab_ci']['user']
  destination node['gitlab_ci']['home']
  repository "https://github.com/gitlabhq/gitlab-ci.git"
  reference "2-2-stable"
  action :checkout
end

[ "#{node['gitlab_ci']['home']}/tmp", "#{node['gitlab_ci']['home']}/tmp/pids", "#{node['gitlab_ci']['home']}/tmp/cache", "#{node['gitlab_ci']['home']}/tmp/sockets", "#{node['gitlab_ci']['home']}/public" ].each do |folder|
  directory "#{folder}" do
    owner node['gitlab_ci']['user']
    mode 00755
    recursive true
    action :create
  end
end

# Install Bundler
%w{ bundle }.each do |the_gem|
  gem_package "#{the_gem}" do
    action :install
  end
end

execute "Install Dependencies" do
  user node['gitlab_ci']['user']
  cwd node['gitlab_ci']['home']
  # command "bundle install --deployment --without development test"
  command "bundle install --deployment --without development test"
  action :run
end

# Copy default Puma config
template "#{node['gitlab_ci']['home']}/config/puma.rb" do
  source "gitlab_ci-puma.erb"
  owner node['gitlab_ci']['user']
  mode 00644
end

# Configure mysql
template "#{node['gitlab_ci']['home']}/config/database.yml" do
  source "database-mysql.yml.erb"
  owner node['gitlab_ci']['user']
  mode 00644
end

execute "Configure DB" do
  user node['gitlab_ci']['user']
  cwd node['gitlab_ci']['home']
  environment ({'HOME' => node['gitlab_ci']['home']})
  command "bundle exec rake db:setup RAILS_ENV=production"
  action :run
end

execute "Setup Schedules" do
  user node['gitlab_ci']['user']
  cwd node['gitlab_ci']['home']
  environment ({'HOME' => node['gitlab_ci']['home']})
  command "bundle exec whenever -w RAILS_ENV=production"
  action :run
end

# Install resque config
template "#{node['gitlab_ci']['home']}/config/resque.yml" do
  source "gitlab_ci-resque.yml.erb"
  owner node['gitlab_ci']['user']
  mode 00644
end

# Install init script
template "/etc/init.d/gitlab_ci" do
  source "gitlab_ci-init.erb"
  owner node['gitlab_ci']['user']
  mode 00647
end

service "gitlab_ci" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
