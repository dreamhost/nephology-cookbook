#
# Cookbook Name:: nephology
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

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

include_recipe 'git'

include_recipe 'nephology::nat'
include_recipe 'nephology::dhcpd'
include_recipe 'nephology::server'
