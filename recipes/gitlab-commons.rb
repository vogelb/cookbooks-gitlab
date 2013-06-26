#
# Cookbook Name:: gitlab
# Recipe:: gitlab-commons
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
include_recipe "apt"

# uninstall Ruby 1.8
package "ruby1.8" do
  action :remove
end

# install Ruby 1.9
%w{ ruby1.9.1 ruby1.9.1-dev ri1.9.1 libruby1.9.1 }.each do |pkg|
  package pkg do
    action :install
  end
end

# install newer version of git via ppa
apt_repository "git-core-ppa" do
  uri "http://ppa.launchpad.net/git-core/ppa/ubuntu"
  distribution node['lsb']['codename']
  components ["main"]
  keyserver "hkp://keyserver.ubuntu.com:80"
  key "E1DF1F24"
end.run_action(:add)

package "git" do
  version '1.8.3.1-1'
  action :upgrade
end

# configure git client
execute "configure-git-user" do
  command <<-EOF
    sudo -u git -H git config --global user.name  "GitLab"
    sudo -u git -H git config --global user.email "gitlab@#{node['ipaddress']}"
    EOF
  not_if 'sudo -u git -H git config --global --get user.email'
end

# Install MySQL
node.set['mysql']['gitlab_user'] = "gitlab"
node.set['mysql']['gitlab_password'] = "gitlab"
include_recipe 'mysql::server'
include_recipe 'mysql::ruby'
include_recipe 'database::mysql'

node.set['mysql']['connection'] = { :host => 'localhost',
                    :username => 'root',
                    :password => node['mysql']['server_root_password'] }

