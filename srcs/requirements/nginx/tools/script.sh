#!/bin/bash
set -e

# Check if the DOMAIN environment variable is set, otherwise default to localhost
CN="${DOMAIN:-localhost}"

# Generate SSL certificate if it does not exist
if [ ! -f /etc/ssl/private/nginx.key ] || [ ! -f /etc/ssl/certs/nginx.crt ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/ssl/private/nginx.key \
		-out /etc/ssl/certs/nginx.crt \
		-subj "/C=PT/ST=Lisbon/L=Lisbon/O=School42/OU=yadereve/CN=$CN"
fi

chmod 600 /etc/ssl/private/nginx.key
chmod 644 /etc/ssl/certs/nginx.crt

exec nginx -g 'daemon off;'
