NGINX PHP FastCGI Server Configuration - with Adminer
=====================================================

`NGINX`_ is a web server, load balancer and reverse proxy with a strong
focus on performance, high concurency (over 10,000 simultaneous
connections), and low memory usage. It powers many of the world's
largest websites. NGINX can deploy dynamic HTTP content such as PHP
scripts using the FastCGI interface.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

- NGINX configured to proxy PHP requests to the PHP-FastCGI daemon.
- MariaDB (drop-in MySQL replacement).
- Includes TurnKey Web Control panel with links to useful
  references and resources (convenience).
- SSL support out of the box.
- `Adminer`_ administration frontend for MySQL (listening on port
  12322 - uses SSL).
- Postfix MTA (bound to localhost) to allow sending of email (e.g.,
  password recovery).
- Webmin modules for configuring PHP, MySQL and Postfix.

Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH, MySQL: username **root**

-  Adminer: username **adminer**

.. _NGINX: http://nginx.org
.. _TurnKey Core: https://www.turnkeylinux.org/core
.. _Adminer: http://www.adminer.org
