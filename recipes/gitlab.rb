#
# Cookbook Name:: gitlab
# Recipe:: gitlab
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

# Create git user
user node['gitlab']['user'] do
  comment 'GitLab'
  home "/home/#{node['gitlab']['user']}"
  shell '/bin/false'
  gid node['gitlab']['group']
  supports :manage_home => true, :non_unique => false
  action :create
end

include_recipe "gitlab::gitlab-commons"

# Install packages
node['gitlab']['packages'].each do |base_package|
  package base_package do
    action :install
  end
end

# Create mysql user
mysql_database_user node['mysql']['gitlab_user'] do
  connection node['mysql']['connection']
  password node['mysql']['gitlab_password']
  action :create
end

# Create databases and users
%w{ gitlabhq_production }.each do |db|
  mysql_database "#{db}" do
    connection node['mysql']['connection']
    action :create
  end
end

# Grant all privelages on all databases/tables from localhost to mysql user
mysql_database_user node['mysql']['gitlab_user'] do
  connection node['mysql']['connection']
  password node['mysql']['gitlab_password']
  action :grant
end

# Checkout gitlab-shell
git 'gitlab-shell' do
  user node['gitlab']['user']
  destination "/home/#{node['gitlab']['user']}/gitlab-shell"
  repository "https://github.com/gitlabhq/gitlab-shell.git"
  reference "v1.4.0"
  action :checkout
end

template "/home/#{node['gitlab']['user']}/gitlab-shell/config.yml" do
  source "gitlab-shell-config.yml.erb"
  owner node['gitlab']['user']
  group node['gitlab']['group']
  mode 00644
end

execute "install_gitlab" do
  user node['gitlab']['user']
  group node['gitlab']['group']
  command "/home/#{node['gitlab']['user']}/gitlab-shell/bin/install"
  action :run
end

# Checkout gitlabhq
git 'gitlab-hq' do
  user node['gitlab']['user']
  group node['gitlab']['group']
  destination node['gitlab']['home']
  repository "https://github.com/gitlabhq/gitlabhq"
  reference "5-2-stable"
  action :checkout
end

# Configure gitlabhq
template "#{node['gitlab']['home']}/config/gitlab.yml" do
  source "gitlab-hq-config.yml.erb"
  owner node['gitlab']['user']
  group node['gitlab']['group']
  mode 00644
end

[ "/home/#{node['gitlab']['user']}/gitlab-satellites",  "#{node['gitlab']['home']}/tmp/pids",  "#{node['gitlab']['home']}/tmp/sockets", "#{node['gitlab']['home']}/public/uploads"].each do |folder|
  directory "#{folder}" do
    owner node['gitlab']['user']
    group node['gitlab']['group']
    mode 00755
    recursive true
    action :create
  end
end

# Copy default Puma config
template "#{node['gitlab']['home']}/config/puma.rb" do
  source "gitlab-puma.erb"
  owner node['gitlab']['user']
  group node['gitlab']['group']
  mode 00644
end

# Configure mysql
template "#{node['gitlab']['home']}/config/database.yml" do
  source "database-mysql.yml.erb"
  owner node['gitlab']['user']
  group node['gitlab']['group']
  variables({
    :database => 'gitlabhq_production'
  })
  mode 00644
end

# Install Bundler
gem_package "bundler" do
  action :install
end

gem_package "charlock_holmes" do
  version "0.6.9.4"
  action :install
end

execute "install_gitlabhq" do
  user node['gitlab']['user']
  group node['gitlab']['group']
  cwd node['gitlab']['home']
  command "bundle install --deployment --without development test postgres"
  action :run
end

execute "setup_gitlabhq" do
  user node['gitlab']['user']
  group node['gitlab']['group']
  cwd node['gitlab']['home']
  command "bundle exec rake gitlab:setup RAILS_ENV=production force=yes"
  action :run
end

# cp lib/support/init.d/gitlab /etc/init.d/gitlab
# chmod +x /etc/init.d/gitlab
ruby_block "Copy init script" do
  block do
    ::FileUtils.cp "#{node['gitlab']['home']}/lib/support/init.d/gitlab", "/etc/init.d/gitlab"
    ::FileUtils.chmod "u+x", "/etc/init.d/gitlab"
  end
  not_if { File.exist?("/etc/init.d/gitlab")}
end

execute "info_gitlabhq" do
  user node['gitlab']['user']
  cwd node['gitlab']['home']
  command "bundle exec rake gitlab:env:info RAILS_ENV=production force=yes"
  action :run
end

# update-rc.d gitlab defaults 21
service "gitlab" do
 supports :status => true, :restart => true, :reload => true
 action [ :enable, :start ]
end



