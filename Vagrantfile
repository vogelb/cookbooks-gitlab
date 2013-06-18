# -*- mode: ruby -*-
# vi: set ft=ruby :

def configure_provider(provider, config, config_lambda)
  config.vm.provider provider do |prvdr, override|
    config_lambda.call(prvdr, override)
  end
end

def vbox_config(name, ip, memory_size = 384)
  lambda do |vbox, override|
    # override box url
    override.vm.box = "opscode_ubuntu-12.04_provisionerless"
    override.vm.box_url = "https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box"
    # configure host-only network
    override.vm.hostname = "#{name}.local"
    override.vm.network :private_network, ip: ip
    # enable cachier for local vbox vms
    override.cache.auto_detect = true
 
    # virtualbox specific configuration
    vbox.customize ["modifyvm", :id,
      "--memory", memory_size,
      "--name", name
    ]
  end
end

def aws_config(instance_type)
  lambda do |aws, override|
    # use dummy box
    override.vm.box = "aws_dummy_box"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
    # override ssh user and private key
    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = "#{ENV['HOME']}/.ssh/chef-tlc-insecure-key"
    
    # aws specific settings
    aws.access_key_id = ENV['AWS_ACCESS_KEY']
    aws.secret_access_key = ENV['AWS_SECRET_KEY']
    aws.ami = "ami-524e4726"
    aws.region = "eu-west-1"
    aws.availability_zone = "eu-west-1c"
    aws.instance_type = instance_type
    aws.security_groups = [ "ssh", "http" ]
    aws.keypair_name = "chef-tlc-insecure-key"
  end
end

def esx_config(server)
  lambda do |managed, override|
    # use dummy box
    override.vm.box = "managed_dummy_box"
    override.vm.box_url = "https://github.com/tknerr/vagrant-managed-servers/raw/master/dummy.box"
    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = "#{ENV['HOME']}/.ssh/chef-tlc-insecure-key"
    # link with this server
    managed.server = server
  end
end

#
# Vagrantfile for testing
#
# NOTE: you need the following plugin: vagrant-plugin-bundler
#
Vagrant::configure("2") do |config|

  # Plugin
  config.plugin.deps do
    depend 'vagrant-aws', '0.2.2.rsyncfix'
    depend 'vagrant-managed-servers', '0.1.0'
    depend 'vagrant-omnibus', '1.0.2'
    depend 'vagrant-cachier', '0.1.0'
  end

  # the Chef version to use
  config.omnibus.chef_version = "11.4.4"

  # define a separate VMs for the 3 providers (vbox, aws, managed)
  # because with Vagrant 1.2.2 you can run a VM with only one provider at once
  #
  [:aws, :vbox, :esx].each do |provider|
    #
    # Sample VM per provider
    #
    config.vm.define :"gitlab-#{provider}" do | sample_app_config |

      case provider
      when :vbox
        configure_provider(:virtualbox, sample_app_config, vbox_config("gitlab", "33.33.33.10", 3096))
      when :aws
        configure_provider(:aws, sample_app_config, aws_config("m1.medium"))
      when :esx
        configure_provider(:managed, sample_app_config, esx_config("192.168.200.225"))
      end
      
      sample_app_config.vm.provision :chef_solo do |chef|
        chef.cookbooks_path = "./cookbooks"
        if provider == :vbox
          chef.add_recipe "gitlab::gitlab-vagrant"
        end
        chef.add_recipe "gitlab"
        chef.json = {
          :mysql => {
              :server_root_password => "nonrandompasswordsaregreattoo",
              :server_debian_password => "nonrandompasswordsaregreattoo",
              :server_repl_password => "nonrandompasswordsaregreattoo"
          }
        }
      end
    end
  end
end
