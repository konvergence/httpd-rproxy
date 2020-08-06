#!/bin/bash

: ${PROXY_URI:?"Missing variable PROXY_URI"}

: ${PROXY_URI_PREFIX:=/}

: ${BASIC_AUTH_STRING:="Basic authentication"}
: ${REQUIRE_COND:="Require valid-user"}
: ${LISTEN_PORT:=80}
: ${LOGLEVEL:=warn}
: ${ENABLE_WEBSOCKET:=yes}
: ${SERVERNAME:=localhost.localdomain}
: ${ENABLE_XFF_LOG:=yes}


: ${BASIC_AUTH_USER:?"Missing variable BASIC_AUTH_USER"}
: ${BASIC_AUTH_PASSWORD:?"Missing variable BASIC_AUTH_PASSWORD"}


eval "cat > /usr/local/apache2/conf/proxy.conf << EOF
$(cat /proxy.conf.template)
EOF"

sed -i -e 's/^Listen/# Listen/' /usr/local/apache2/conf/httpd.conf

pushd /usr/local/apache2/conf/
[ "${ENABLE_XFF_LOG}" == "yes" ] && ln -sf log_format_xff.conf  log_format.conf || ln -sf log_format_normal.conf  log_format.conf
popd

[[ -v DISPLAY_CONFIG ]] && {
  cat /usr/local/apache2/conf/proxy.conf
}



htpasswd -b -c  /usr/local/apache2/conf/.htpasswd ${BASIC_AUTH_USER} ${BASIC_AUTH_PASSWORD}


# base image CMD
httpd-foreground
