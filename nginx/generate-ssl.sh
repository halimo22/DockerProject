#!/bin/bash
ssl_dir=/etc/nginx/ssl/
ssl_key=$ssl_dir/nginx.key
ssl_cert=$ssl_dir/nginx.crt
if [ -f "$ssl_key" ] && [ -f "$ssl_cert" ]; then
    echo "SSL certificates already exist. No need to generate."
else
    echo "SSL certificates do not exist. Generating new certificates..."
    
    mkdir -p $ssl_dir

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout $ssl_key -out $ssl_cert -subj "/CN=localhost"

    echo "SSL certificates have been generated and stored in $ssl_dir."
fi