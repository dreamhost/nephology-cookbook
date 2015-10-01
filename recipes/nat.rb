# mainly for the vagrant nephology network, can be used in some
# special network cases

bash 'setup nat' do
  code <<-EOH
    echo 1 > /proc/sys/net/ipv4/ip_forward
    /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    /sbin/iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
    /sbin/iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
  EOH
end
