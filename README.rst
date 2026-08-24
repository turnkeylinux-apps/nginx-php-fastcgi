NGINX PHP FastCGI Server Configuration - with Adminer
=====================================================

`NGINX`_ is a web server, load balancer and reverse proxy with a strong
focus on performance, high concurrency and low memory usage. NGINX can
deploy dynamic HTTP content such as PHP scripts using the FastCGI
interface.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

- NGINX configured to proxy PHP requests to the PHP-FastCGI daemon.
- NGINX, PHP-FPM, MariaDB, Adminer and mysqltuner installed and maintained
  through Debian's package management system.
- MariaDB (drop-in MySQL replacement).
- TurnKey Web Control panel with links to useful references and resources.
- TLS support out of the box.
- `Adminer`_ administration frontend for MySQL (listening on port
  12322 - uses TLS).
- Postfix MTA (bound to localhost) to allow sending of email (e.g.,
  password recovery).
- Webmin modules for configuring PHP, MySQL and Postfix.

Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH, MySQL: username **root**

-  Adminer: username **adminer**

.. _NGINX: https://nginx.org
.. _TurnKey Core: https://www.turnkeylinux.org/core
.. _Adminer: https://www.adminer.org
