Nephology Cookbook
==================

Cookbook for deployment of nephology ( https://github.com/dreamhost/nephology-server-perl )

Recipes
=======

server
------
Installs nephology server and dependencies. Sets up nginx to proxy connections
to carton.

dhcpd
-----
Installs dhcp, tftp

ipxe
----
Builds custom ipxe image

nat
---
Sets up basic nat rules for nephology network


Requirements
------------

Vagrant
* vagrant >= 1.7.x
* vagrant-berkshelf
* chefdk
