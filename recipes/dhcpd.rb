include_recipe 'dhcp::server'

dhcp_subnet node['nephology']['dhcp_subnet'] do
  pool do
    range node['nephology']['dhcp_range']
  end
  netmask node['nephology']['dhcp_netmask']
  broadcast node['nephology']['dhcp_broadcast']
  options [ "time-offset 10" ]
  next_server node['nephology']['dhcp_next_server']
  routers node['nephology']['dhcp_routers']
  evals [ %q|
    filename "/ipxe";
  | ]
end 
