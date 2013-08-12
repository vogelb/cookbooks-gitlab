#
# see https://gist.github.com/fgrehm/b07c6370a710be622807#file-02-ubuntu-vagrantfile-rb
#

# install LXC packages
%w{ lxc redir htop btrfs-tools apparmor-utils linux-image-generic linux-headers-generic }.each do |pkg|
  package pkg
end

# loosen security policy
bash "sudo aa-complain /usr/bin/lxc-start"

