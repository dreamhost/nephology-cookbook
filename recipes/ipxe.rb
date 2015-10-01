include_recipe 'build-essential'
include_recipe 'git'
include_recipe 'tftp::server'

%w{ genisoimage liblzma-dev }.each { |pkg| package pkg }

git '/opt/ipxe' do
  repository 'git://git.ipxe.org/ipxe.git'
  reference 'HEAD'
  action :sync
end

int = node['nephology']['interface']
neph_ip = node['network']['interfaces'][int]['addresses'].map {|i| i.first if i.last["family"].eql?("inet") }.compact.first
template '/opt/ipxe/nephology.ipxe' do
  source 'nephology.ipxe.erb'
  variables(
    'neph_ip' => neph_ip
  )
end

bash 'build ipxe image' do
  cwd '/opt/ipxe/src'
  code <<-EOH
    make EMBED=/opt/ipxe/nephology.ipxe
    cp bin/ipxe.pxe /var/lib/tftpboot/ipxe
  EOH
end
