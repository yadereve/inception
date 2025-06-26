#!/bin/zsh
# Adds an entry to /etc/hosts for DOMAIN and www.DOMAIN if not already present

# Try to load DOMAIN from .env if not set
if [ -z "yadereve.42.fr" ] && [ -f ../../.env ]; then
	export yadereve.42.fr=$(grep '^yadereve.42.fr=' ../../.env | cut -d'=' -f2)
	echo "Loaded DOMAIN from .env: yadereve.42.fr"
fi

HOST_LINE="127.0.0.1 yadereve.42.fr"

if ! grep -q "yadereve.42.fr" /etc/hosts; then
	echo "$HOST_LINE" | sudo tee -a /etc/hosts
else
	echo "✔ Domain yadereve.42.fr is already present in /etc/hosts."
fi
