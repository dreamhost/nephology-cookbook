include_recipe 'nephology::ipxe'

package 'isc-dhcp-server' do
  action :install
end

execute "restart dhcpd" do
  command 'service isc-dhcp-server restart'
end

cookbook_file '/etc/dhcp/dhcpd.conf' do
  source 'dhcpd.conf'
  notifies :run, 'execute[restart dhcpd]', :immediately
end
