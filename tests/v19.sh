#!/bin/bash
set -Eeuo pipefail
umask 077

result=${TKL_TEST_RESULT:?TKL_TEST_RESULT is required}
db_password=${TKL_TEST_DB_PASS:?TKL_TEST_DB_PASS is required}
database=tkl_v19_smoke_$$
table=tkl_main_flow
document_root=/var/www
php_test=$document_root/tkl-v19-db.php
password_file=/run/tkl-v19-tests/nginx-db-pass.$$
response=/tmp/tkl-nginx-response.$$
cookies=/tmp/tkl-nginx-adminer-cookies.$$
policy=/tmp/tkl-nginx-policy.$$

cleanup() {
    rm -f -- "$php_test" "$password_file" "$response" "$cookies" "$policy"
    mysql --user=root --password="$db_password" \
        --execute="DROP DATABASE IF EXISTS \`$database\`;" >/dev/null 2>&1 || true
}
trap cleanup EXIT

php_fpm_service=$(systemctl list-unit-files 'php*-fpm.service' --no-legend |
    awk 'NR == 1 {print $1}')
test -n "$php_fpm_service"
systemctl --quiet is-active nginx.service mariadb.service \
    "$php_fpm_service" multi-user.target
nginx -t

nginx_version=$(dpkg-query -W -f='${Version}' nginx)
php_version=$(dpkg-query -W -f='${Version}' php-fpm)
mariadb_version=$(dpkg-query -W -f='${Version}' mariadb-server)
adminer_version=$(dpkg-query -W -f='${Version}' adminer)
mysqltuner_version=$(dpkg-query -W -f='${Version}' mysqltuner)
test "$(command -v mysqltuner)" = /usr/bin/mysqltuner
dpkg-query -S /usr/bin/mysqltuner | grep -q '^mysqltuner:'
test ! -e /usr/local/bin/mysqltuner
test ! -e /usr/local/bin/basic_passwords.txt
test ! -e /usr/local/bin/vulnerabilities.csv

curl --insecure --fail --silent --show-error https://127.0.0.1/ >"$response"
grep -q 'TurnKey NGINX PHP FastCGI Server' "$response"
grep -q ':12321' "$response"
grep -q ':12322' "$response"
curl --insecure --fail --silent --show-error \
    https://127.0.0.1/phpinfo.php >"$response"
grep -q 'PHP Version 8.4' "$response"

mysql --user=root --password="$db_password" <<SQL
CREATE DATABASE \`$database\`;
CREATE TABLE \`$database\`.\`$table\` (message varchar(64) NOT NULL);
INSERT INTO \`$database\`.\`$table\` VALUES ('database-backed-fastcgi-ok');
SQL
printf '%s' "$db_password" >"$password_file"
chown root:www-data "$password_file"
chmod 0640 "$password_file"
cat >"$php_test" <<PHP
<?php
\$password = file_get_contents('$password_file');
\$database = new mysqli('localhost', 'adminer', \$password, '$database');
if (\$database->connect_error) { http_response_code(500); exit('connection-failed'); }
\$query = \$database->query('SELECT message FROM $table');
if (!\$query) { http_response_code(500); exit('query-failed'); }
header('Content-Type: text/plain');
echo \$query->fetch_row()[0];
?>
PHP
chmod 0644 "$php_test"
curl --insecure --fail --silent --show-error \
    https://127.0.0.1/tkl-v19-db.php >"$response"
grep -Fxq 'database-backed-fastcgi-ok' "$response"

curl --insecure --fail --silent --show-error \
    https://127.0.0.1:12322/ >"$response"
grep -qi 'Adminer' "$response"
curl --insecure --silent --show-error --location \
    --cookie-jar "$cookies" --cookie "$cookies" \
    --data-urlencode 'auth[driver]=server' \
    --data-urlencode 'auth[server]=localhost' \
    --data-urlencode 'auth[username]=adminer' \
    --data-urlencode "auth[password]=$db_password" \
    --data-urlencode 'auth[db]=mysql' \
    https://127.0.0.1:12322/ >"$response"
grep -qi 'MariaDB\|MySQL' "$response"
grep -qi 'Logout' "$response"
if grep -qi 'Invalid credentials\|Access denied' "$response"; then
    echo 'Adminer rejected the MariaDB credentials' >&2
    exit 1
fi

dpkg-query -W webmin-mysql webmin-phpini >/dev/null

before="$nginx_version|$php_version|$mariadb_version|$adminer_version|$mysqltuner_version"
apt-get update >/dev/null
for package in nginx php-fpm mariadb-server adminer mysqltuner; do
    apt-cache policy "$package" >"$policy"
    candidate=$(awk '/Candidate:/ {print $2}' "$policy")
    test -n "$candidate"
    test "$candidate" != '(none)'
    grep -Eq 'http://deb\.debian\.org/debian trixie/main' "$policy"
done
after="$(dpkg-query -W -f='${Version}' nginx)|$(dpkg-query -W -f='${Version}' php-fpm)|$(dpkg-query -W -f='${Version}' mariadb-server)|$(dpkg-query -W -f='${Version}' adminer)|$(dpkg-query -W -f='${Version}' mysqltuner)"
test "$after" = "$before"
grep -Rqs '^Suites: trixie' /etc/apt/sources.list.d
! grep -Rqi bookworm /etc/apt/sources.list.d

cat >"$result" <<EOF
package_source=Debian 13 Trixie APT repositories for Nginx, PHP-FPM, MariaDB, Adminer and mysqltuner; TurnKey APT for Webmin modules
installed_version=nginx $nginx_version; php-fpm $php_version; mariadb-server $mariadb_version; adminer $adminer_version; mysqltuner $mysqltuner_version
runtime_checks=normal init; Nginx HTTPS landing and control-panel links; PHP 8.4 through FastCGI; MariaDB root login; database-backed PHP request; Adminer HTTPS and credential login; Debian-owned mysqltuner command; Webmin MariaDB and PHP modules
updater_command=apt-get update; apt-cache policy nginx php-fpm mariadb-server adminer mysqltuner
updater_result=signed metadata refreshed; eligible candidates found; installed versions unchanged
updater_channel=Debian Trixie and TurnKey Trixie APT repositories
integrity_evidence=APT accepted signed repository metadata through configured Deb822 sources and keyrings; no Bookworm source remained
EOF
