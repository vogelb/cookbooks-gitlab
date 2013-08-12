#
# include extension recipes if enabled
#

available_extensions = node['gitlab_ci']['extensions'] || {}

available_extensions.each do |name, enabled|
  if enabled
    include_recipe "gitlab::gitlab-ci-extension-#{name}"
  end
end