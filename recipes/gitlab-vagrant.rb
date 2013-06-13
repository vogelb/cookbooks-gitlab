node.set['rvm']['vagrant']['system_chef_solo'] = '/opt/chef/bin/chef-solo'
include_recipe "vagrant-ohai"
include_recipe "rvm::vagrant"