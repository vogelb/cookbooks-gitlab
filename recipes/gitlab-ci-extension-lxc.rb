#
# see https://gist.github.com/fgrehm/b07c6370a710be622807#file-02-ubuntu-vagrantfile-rb
#

# install LXC packages
%w{ lxc redir htop btrfs-tools apparmor-utils linux-image-generic linux-headers-generic }.each do |pkg|
  package pkg
end

# loosen security policy
bash "sudo aa-complain /usr/bin/lxc-start"

# set VAGRANT_DEFAULT_PROVIDER to lxc
file "/etc/profile.d/vagrant-lxc.sh" do
  action :create
  owner "root"
  group "root"
  mode 00644
  content <<-EOH
  export VAGRANT_DEFAULT_PROVIDER=lxc
  EOH
end

# create wrapper script and allow for passwordless sudo,
# see https://github.com/fgrehm/vagrant-lxc/#avoiding-sudo-passwords
file "/usr/bin/lxc-vagrant-wrapper" do
  action :create
  owner "root"
  group "root"
  mode 00755
  content <<-EOF
#!/usr/bin/env ruby
exec ARGV.join(' ')
EOF
end

file "/etc/sudoers.d/git-lxc" do
  action :create
  owner "root"
  group "root"
  mode 00440
  content <<-EOF
  #{node['gitlab_ci']['user']} ALL=NOPASSWD:/usr/bin/lxc-vagrant-wrapper
  EOF
end
