Nginx PHP FastCGI Server Configuration - with Adminer
=====================================================

`Nginx`_ is a web server, load balancer and reverse proxy with a strong
focus on performance, high concurency (over 10,000 simultaneous
connections), and low memory usage. It powers many of the world's
largest websites. Nginx can deploy dynamic HTTP content such as PHP
scripts using the FastCGI interface.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

- Nginx configured to proxy PHP requests to the PHP-FastCGI daemon.
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

-  Webmin, SSH, MySQL, Adminer: username **root**


.. _Nginx: http://nginx.org
.. _TurnKey Core: http://www.turnkeylinux.org/core
.. _Adminer: http://www.adminer.org
