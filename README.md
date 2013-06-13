gitlab Cookbook
===============
Chef Cookbook for installation of GitLab starting version 5.

Status: Currently under heavy construction!

Default admin credentials:

- User – admin@local.host
- Password – 5iveL!fe

Requirements
------------

#### recipies
*  apt, 2.0.0
* rvm, 0.9.0
* mysql
* database
* vagrant-ohai

Attributes
----------

#### gitlab::gitlab
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['gitlab']['user']</tt></td>
    <td>String</td>
    <td>The user to run gitlab</td>
    <td><tt>gitlab</tt></td>
  </tr>
  <tr>
    <td><tt>['gitlab']['password']</tt></td>
    <td>String</td>
    <td>The password for the gitlab user</td>
    <td><tt>gitlab</tt></td>
  </tr>
  <tr>
    <td><tt>['gitlab']['home']</tt></td>
    <td>String</td>
    <td>The installation root for gitlab</td>
    <td><tt>/home/#{node['gitlab']['user']}/gitlab</tt></td>
  </tr>
</table>

#### gitlab::gitlab-ci
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['gitlab_ci']['user']</tt></td>
    <td>String</td>
    <td>The user to run gitlab ci</td>
    <td><tt>gitlab</tt></td>
  </tr>
  <tr>
    <td><tt>['gitlab_ci']['password']</tt></td>
    <td>String</td>
    <td>The password for the gitlab ci user</td>
    <td><tt>gitlab</tt></td>
  </tr>
  <tr>
    <td><tt>['gitlab_ci']['home']</tt></td>
    <td>String</td>
    <td>The installation root for gitlab</td>
    <td><tt>/home/#{node['gitlab_ci']['user']}/gitlab</tt></td>
  </tr>
</table>

#### gitlab::nginx
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['nginx']['config']</tt></td>
    <td>String</td>
    <td>The config template to use for nginx</td>
    <td><tt>nginx-available-gitlab-plus-ci.erb</tt></td>
  </tr>
</table>

Usage
-----
#### gitlab::default
Installs GitLab, GitLab CI and nginx

Just include `gitlab` in your node's `run_list`. You have to sepcify the following passwords for MySQL

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[gitlab]"
  ]
  "mysql": {
          server_root_password : "nonrandompasswordsaregreattoo"
          server_debian_password : "nonrandompasswordsaregreattoo"
          server_repl_password : "nonrandompasswordsaregreattoo"
  }
}

```

#### gitlab::gitlab
Installs GitLab only. 

#### gitlab::gitlab-ci
Installs GitLab CI only

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Benno Vogel, Torben Knerr
