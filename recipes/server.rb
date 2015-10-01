::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe 'git'
include_recipe 'cpan'
include_recipe 'runit'
include_recipe 'nginx'

package_depends = %w{ carton perl-doc apt-cacher-ng }

package package_depends do
  action :install
end

if node["developer_mode"]
  node.set_unless['nephology']['db']['password'] = 'nephology'
  node.set_unless['nephology']['db']['rootpass'] = 'nephology'
else
  node.set_unless['nephology']['db']['password'] = secure_password
  node.set_unless['nephology']['db']['rootpass'] = secure_password
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

runit_service 'nephology-server' do
  default_logger true
  finish true
end

git '/opt/nephology-server' do
  repository node['nephology']['server']['repo']
  reference node['nephology']['server']['ref']
  action :sync
  notifies :restart, "runit_service[nephology-server]"
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
  initial_root_password node['nephology']['db']['rootpass']
  action [:create, :start]
end
  node['nephology']['db']['password']

mysql_connection_info  = {
    :host     => node['nephology']['db']['host'],
    :username => 'root',
    :socket   => '/var/run/mysql/mysqld.sock',
    :password => node['nephology']['db']['rootpass']
}

mysql_database node['nephology']['db']['name'] do
  connection mysql_connection_info
  action :create
end

mysql_database_user node['nephology']['db']['user'] do
  connection mysql_connection_info
  password node['nephology']['db']['password']
  database_name node['nephology']['db']['name']
  host '%'
  privileges [:all]
  require_ssl false
  action :grant
end

bash 'import nephology schema' do
  code <<-EOH
    mysql -u#{node['nephology']['db']['user']} -p#{node['nephology']['db']['password']} #{node['nephology']['db']['name']} < /opt/nephology-server/sql/schema.sql
  EOH
end

bash 'carton install nephology server depends' do
  cwd '/opt/nephology-server'
  code <<-EOH
    carton install
  EOH
end

int = node['nephology']['interface']
neph_ip = node['network']['interfaces'][int]['addresses'].map {|i| i.first if i.last["family"].eql?("inet") }.compact.first
template '/opt/nephology-server/etc/config.yaml' do
  source 'config.yaml.erb'
  variables(
    'neph_ip' => neph_ip
  )
  notifies :restart, "runit_service[nephology-server]"
end

link '/etc/nephology/config.yaml' do
  to '/opt/nephology-server/etc/config.yaml'
end

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

bash "create nephology ssh key" do
  cwd '/etc/nephology'
  code <<-EOH
    ssh-keygen -f #{node['nephology']['ssh_key_file']} -t rsa -N ''
  EOH
  not_if { ::File.exists?("#{node['nephology']['ssh_key_file']}.pub") }
end
