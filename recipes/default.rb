#
# Cookbook Name:: gitlab
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
include_recipe "gitlab::gitlab"
include_recipe "gitlab::gitlab-ci"
include_recipe "gitlab::gitlab-ci-extensions"
include_recipe "gitlab::nginx"