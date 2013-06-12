# MySQL parameters
node.default['mysql']['root_password'] = "nonrandompasswordsaregreattoo"
node.set['mysql']['server_root_password'] = node['mysql']['root_password']
node.set['mysql']['server_debian_password'] = node['mysql']['root_password']
node.set['mysql']['server_repl_password'] = node['mysql']['root_password']