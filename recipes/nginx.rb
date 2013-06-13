#
# Cookbook Name:: gitlab
# Recipe:: gitlab-commons
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
template "#{node['gitlab']['home']}/lib/support/nginx/gitlab" do
  source node['ngingx']['config']
  owner node['gitlab']['user']
  mode 00644
end

execute "copy_nginx_available_list" do
  command "cp #{node['gitlab']['home']}/lib/support/nginx/gitlab /etc/nginx/sites-available/gitlab"
  action :run
end

link "/etc/nginx/sites-enabled/gitlab" do
  to "/etc/nginx/sites-available/gitlab"
end

template "#{node['gitlab']['home']}/public/index.html" do
  source "home.html.erb"
  owner node['gitlab']['user']
  mode 00644
end

service "nginx" do
  action :restart
end