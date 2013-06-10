#
# Cookbook Name:: gitlab
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

include_recipe "apt"

packages = %w{ build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl git-core openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev python }
packages.each do |base_package|
  package base_package do
    action :install
  end
end

node.set['rvm']['vagrant']['system_chef_solo'] = '/opt/chef/bin/chef-solo'
include_recipe "rvm::vagrant"

node.set['rvm']['global_gems'] = [{ :name => 'bundler'}]
node.set['rvm']['branch'] = 'none'
node.set['rvm']['version'] = '1.17.10'
include_recipe "rvm::system"

#gem_package "bundler" do
#  action :install
#end

user 'git' do
  username 'git'
  comment 'GitLab'
  home '/home/git'
  shell '/bin/false'
  supports :manage_home => true, :non_unique => false
  action :create
end

git 'gitlab-shell' do
  user "git"
  destination "/home/git/gitlab-shell"
  repository "https://github.com/gitlabhq/gitlab-shell.git"
  reference "v1.4.0"
  action :checkout
end

template "/home/git/gitlab-shell/config.yml" do
  source "config.yml.erb"
  owner "git"
  mode 00644
end

execute "install_gitlab" do
  user "git"
  command "/home/git/gitlab-shell/bin/install"
  action :run
end

