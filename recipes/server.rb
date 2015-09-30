::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe 'git'

if node["developer_mode"]
  node.set_unless['nephology']['password'] = 'nephology'
else
  node.set_unless['nephology']['password'] = secure_password
end

user 'nephology' do
  comment 'nephology user'
  home '/var/nephology'
  shell '/bin/bash'
  action :create
  manage_home true
end

directory '/var/nephology/boot-images' do
  action :create
  owner 'nephology'
end

directory '/etc/nephology' do
  action :create
  owner 'nephology'
end

git '/opt/nephology-server' do
  repository node['nephology']['server']['repo']
  reference node['nephology']['server']['ref']
  action :sync
end

mysql2_chef_gem 'default' do
  action :install
end

mysql_client 'default' do
  action :create
end

mysql_service 'nephology' do
  port '3306'
  version '5.5'
  socket '/var/run/mysqld/mysqld.sock'
  initial_root_password node['nephology']['password']
  action [:create, :start]
end

mysql_connection_info  = {
    :host     => '127.0.0.1',
    :username => 'root',
    :socket   => '/var/run/mysql/mysqld.sock',
    :password => node['nephology']['password']
}

mysql_database 'nephology' do
  connection mysql_connection_info
  action :create
end

bash 'import nephology schema' do
  code <<-EOH
    mysql -uroot -p#{node['nephology']['password']} nephology < /opt/nephology-server/sql/schema.sql
  EOH
end

include_recipe 'cpan'

cpan_client 'Carton' do
  user 'root'
  group 'root'
  force true
  install_type 'cpan_module'
  action 'install'
end


bash 'carton install' do
  cwd '/opt/nephology-server'
  code <<-EOH
    carton install
  EOH
end

template '/opt/nephology-server/etc/config.yaml' do
  source 'config.yaml.erb'
end

link '/etc/nephology/config.yaml' do
  to '/opt/nephology-server/etc/config.yaml'
end

include_recipe 'runit'
runit_service 'nephology-server' do
  default_logger true
  finish true
end

include_recipe 'nginx'

template "/etc/nginx/sites-available/nephology" do
  source "nephology-site.erb"
end

nginx_site 'default' do
  enable false
end

nginx_site 'nephology' do
  template false
end

link '/var/nephology/scripts' do
  to '/opt/nephology-server/scripts'
end

remote_file '/var/nephology/boot-images/vmlinuz' do
  source node['nephology']['boot_kernel']
  mode '0755'
  action :create
end

remote_file '/var/nephology/boot-images/initrd.gz' do
  source node['nephology']['boot_initrd']
  mode '0755'
  action :create
end

package 'apt-cacher-ng' do
  action :install
end

bash "create nephology ssh key" do
  cwd '/etc/nephology'
  code <<-EOH
    ssh-keygen -f #{node['nephology']['ssh_key_file']} -t rsa -N ''
  EOH
  not_if { ::File.exists?("#{node['nephology']['ssh_key_file']}.pub") }
end
