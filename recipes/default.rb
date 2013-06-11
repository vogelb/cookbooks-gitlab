#
# Cookbook Name:: gitlab
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

include_recipe "apt"
include_recipe "vagrant-ohai"

packages = %w{ build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl git-core openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev python }
packages.each do |base_package|
  package base_package do
    action :install
  end
end

node.set['rvm']['vagrant']['system_chef_solo'] = '/opt/chef/bin/chef-solo'
include_recipe "rvm::vagrant"

# Create git user
user 'git' do
  username 'git'
  comment 'GitLab'
  home '/home/git'
  shell '/bin/false'
  supports :manage_home => true, :non_unique => false
  action :create
end

#node.set['rvm']['user_gems'] = [{ :name => 'bundler'}]
node.set['rvm']['branch'] = 'none'
node.set['rvm']['version'] = '1.17.10'
#node.set['rvm']['group_users'] = ['git']
include_recipe "rvm::system"

# Checkout gitlab-shell
git 'gitlab-shell' do
  user "git"
  destination "/home/git/gitlab-shell"
  repository "https://github.com/gitlabhq/gitlab-shell.git"
  reference "v1.4.0"
  action :checkout
end

template "/home/git/gitlab-shell/config.yml" do
  source "gitlab-shell-config.yml.erb"
  owner "git"
  mode 00644
end

execute "install_gitlab" do
  user "git"
  command "/home/git/gitlab-shell/bin/install"
  action :run
end


# Use mysql as our database
#template "/home/git/gitlab-shell/config/database.yml" do
#  source 'database.yml'
#  user node['gitlab']['host_user_id']
#  group node['gitlab']['host_group_id']
#  mode 0644
#end

node.set['mysql']['server_root_password'] = "nonrandompasswordsaregreattoo"
node.set['mysql']['server_repl_password'] = "nonrandompasswordsaregreattoo"
node.set['mysql']['server_debian_password'] = "nonrandompasswordsaregreattoo"
include_recipe 'mysql::server'
include_recipe 'mysql::ruby'
include_recipe 'database::mysql'

mysql_connexion = { :host => 'localhost',
                    :username => 'root',
                    :password => node['mysql']['server_root_password'] }

# Create mysql user vagrant
mysql_database_user 'git' do
  connection mysql_connexion
  password 'gitlab'
  action :create
end

# Create databases and users
%w{ gitlabhq_production gitlabhq_development gitlabhq_test }.each do |db|
  mysql_database "#{db}" do
    connection mysql_connexion
    action :create
  end
end

# Grant all privelages on all databases/tables from localhost to vagrant
mysql_database_user 'git' do
  connection mysql_connexion
  password 'gitlab'
  action :grant
end

# Checkout gitlabhq
git 'gitlab-hq' do
  user "git"
  destination "/home/git/gitlab"
  repository "https://github.com/gitlabhq/gitlabhq"
  reference "5-2-stable"
  action :checkout
end

# Configure gitlabhq
template "/home/git/gitlab/config/gitlab.yml" do
  source "gitlab-hq-config.yml.erb"
  owner "git"
  mode 00644
end

%w{ /home/git/gitlab-satellites /home/git/gitlab/tmp/pids /home/git/gitlab/tmp/sockets /home/git/gitlab/public/uploads }.each do |folder|
  directory "#{folder}" do
    owner "git"
    mode 00755
    recursive true
    action :create
  end
end

# Copy default Puma config
template "/home/git/gitlab/config/puma.rb" do
  source "puma.erb"
  owner "git"
  mode 00644
end

# Configure mysql
template "/home/git/gitlab/config/database.yml" do
  source "database-mysql.yml.erb"
  owner "git"
  mode 00644
end

gem_package "bundler" do
  action :install
end

gem_package "charlock_holmes" do
  version "0.6.9.4"
  action :install
end

execute "install_gitlabhq" do
  user "git"
  cwd "/home/git/gitlab"
  command "bundle install --deployment --without development test postgres"
  action :run
end

execute "setup_gitlabhq" do
  user "git"
  cwd "/home/git/gitlab"
  command "bundle exec rake gitlab:setup RAILS_ENV=production force=yes"
  action :run
end

# cp lib/support/init.d/gitlab /etc/init.d/gitlab
# chmod +x /etc/init.d/gitlab
ruby_block "Copy init script" do
  block do
    ::FileUtils.cp "/home/git/gitlab/lib/support/init.d/gitlab", "/etc/init.d/gitlab"
    ::FileUtils.chmod "u+x", "/etc/init.d/gitlab"
  end
  not_if { File.exist?("/etc/init.d/gitlab")}
end

execute "info_gitlabhq" do
  user "git"
  cwd "/home/git/gitlab"
  command "bundle exec rake gitlab:env:info RAILS_ENV=production force=yes"
  action :run
end

# update-rc.d gitlab defaults 21
service "gitlab" do
 supports :status => true, :restart => true, :reload => true
 action [ :enable, :start ]
end

package "nginx" do
  options "-y"
  action :install
end

# **YOUR_SERVER_FQDN** to the fully-qualified
# domain name of your host serving GitLab. Also, replace
# the 'listen' line with the following:
#   listen 80 default_server;         # e.g., listen 192.168.1.1:80;
#sed -i -e "s/YOUR_SERVER_IP/*/" -e "s/YOUR_SERVER_FQDN/$SERVERNAME/" /etc/nginx/sites-available/gitlab
template "/home/git/gitlab/lib/support/nginx/gitlab" do
  source "nginx-available-gitlab.erb"
  owner "git"
  mode 00644
end

execute "copy_nginx_available_list" do
  command "cp /home/git/gitlab/lib/support/nginx/gitlab /etc/nginx/sites-available/gitlab"
  action :run
end

link "/etc/nginx/sites-enabled/gitlab" do
  to "/etc/nginx/sites-available/gitlab"
end

service "nginx" do
  action :restart
end

