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

# Install MySQL
node.set['mysql']['gitlab_user'] = "gitlab"
node.set['mysql']['gitlab_password'] = "gitlab"
include_recipe 'mysql::server'
include_recipe 'mysql::ruby'
include_recipe 'database::mysql'

node.set['mysql']['connection'] = { :host => 'localhost',
                    :username => 'root',
                    :password => node['mysql']['server_root_password'] }

