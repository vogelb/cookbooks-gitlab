#
# Cookbook Name:: gitlab
# Recipe:: gitlab-commons
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
include_recipe "apt"

# Install Ruby
node.set['rvm']['branch'] = 'none'
node.set['rvm']['version'] = '1.17.10'
include_recipe "rvm::system"

# Install MySQL
node.set['mysql']['gitlab_user'] = "gitlab"
node.set['mysql']['gitlab_password'] = "gitlab"
include_recipe 'mysql::server'
include_recipe 'mysql::ruby'
include_recipe 'database::mysql'

node.set['mysql']['connection'] = { :host => 'localhost',
                    :username => 'root',
                    :password => node['mysql']['server_root_password'] }

