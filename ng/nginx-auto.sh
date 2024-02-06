#!/bin/bash

set -e

echo "nginx-auto"

nginx_up() {
    if [ -f "/run/nginx/nginx.pid" ]; then
        nginx -s reload
    else
        nginx
    fi

    echo "tail logs"

    tail -f -n 1 /var/log/nginx/*.log
}

main() {
    echo "main"

    mkdir -p /etc/nginx/http.d.bk
    mv /etc/nginx/http.d/*.conf /etc/nginx/http.d.bk || true

    gomplate \
        --file=/etc/ng/templates/nginx-ng.sh \
        --out=/data/nginx-ng.sh \
        --datasource nginx=file:///data/nginx.yaml

    #
    # Public templates (/etc/ng/public)
    # These include custom 40x and 50x error templates.
    #
    gomplate \
        --input-dir=/etc/ng/templates/public \
        --output-dir=/etc/ng/public \
        --template=/etc/ng/templates \
        --datasource nginx=file:///data/nginx.yaml

    #
    # Main nginx.conf (/etc/nginx/nginx.conf)
    #
    gomplate \
        --file=/etc/ng/templates/nginx.conf \
        --out=/etc/nginx/nginx.conf \
        --template=/etc/ng/templates \
        --datasource nginx=file:///data/nginx.yaml


    if [ -d /data/nginx ]; then
        rm -r /data/nginx
    fi
    cp -r /etc/nginx /data

    nginx_up

}


if [ "$0" != "" ]; then
    main &
fi
