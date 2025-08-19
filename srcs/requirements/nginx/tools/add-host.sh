#!/bin/zsh
# Adds an entry to /etc/hosts for DOMAIN and www.DOMAIN if not already present

# Try to load DOMAIN from .env if not set
if [ -z "$DOMAIN" ] && [ -f ../../.env ]; then
	export DOMAIN=$(grep '^DOMAIN=' ../../.env | cut -d'=' -f2)
	echo "Loaded DOMAIN from .env: $DOMAIN"
fi

# Use default domain if still not set
DOMAIN=${DOMAIN:-yadereve.42.fr}

HOST_LINE="127.0.0.1 $DOMAIN"

if ! grep -q "$DOMAIN" /etc/hosts; then
	echo "$HOST_LINE" | sudo tee -a /etc/hosts
	echo "✔ Added $DOMAIN to /etc/hosts"
else
	echo "✔ Domain $DOMAIN is already present in /etc/hosts."
fi
