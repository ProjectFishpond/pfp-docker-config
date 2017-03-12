#!/usr/bin/bash

#start nginx
/opt/local/nginx/sbin/nginx -p /opt/local/nginx -c /opt/conf/nginx/nginx.conf
#start php-rpm
/opt/local/php/sbin/php-fpm --fpm-config /opt/conf/php/php-fpm.conf

tail -f /opt/logs/nginx_pondoffish.error.log
