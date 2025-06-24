#!/bin/bash
set -e

# Generate SSL certificate if it does not exist
if [ ! -f /etc/ssl/private/nginx.key ] || [ ! -f /etc/ssl/certs/nginx.crt ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/ssl/private/nginx.key \
		-out /etc/ssl/certs/nginx.crt \
		-subj "/C=PT/ST=Lisbon/L=Lisbon/O=School42/OU=yadereve/CN=localhost"
fi

exec nginx -g 'daemon off;'
