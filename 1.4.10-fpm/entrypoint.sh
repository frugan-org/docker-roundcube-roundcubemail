#!/bin/bash

# shellcheck disable=SC1091

set -e
#set -o errexit
#set -o nounset
#set -o pipefail
#set -o xtrace # Uncomment this line for debugging purpose


sed -i \
    -e 's/^exec "$@"//' \
    /docker-entrypoint.sh;

#https://stackoverflow.com/a/46433245/3929620
. /docker-entrypoint.sh


if ! grep -q "config.local.inc.php" config/config.inc.php; then
  echo "if( file_exists(__DIR__ . '/config.local.inc.php') ) { include(__DIR__ . '/config.local.inc.php'); }" >> config/config.inc.php
fi


#https://jtreminio.com/blog/running-docker-containers-as-current-host-user/#ok-so-what-actually-works
if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then
  userdel -f www-data;
  if getent group www-data; then
      groupdel www-data;
  fi
  groupadd -g ${GROUP_ID} www-data;
  useradd -l -u ${USER_ID} -g www-data www-data;
  install -d -m 0755 -o www-data -g www-data /home/www-data;

  #https://stackoverflow.com/q/65574334/3929620
  chown -Rf ${USER_ID}:${GROUP_ID} /var/www/html

  #TODO - ERROR: failed to open error_log (/proc/self/fd/2): Permission denied (13)
  #https://stackoverflow.com/a/47081858/3929620
  #https://superuser.com/a/1145014
  #set -- 'runuser' '-u' 'www-data' '-c' "$@"

  #https://stackoverflow.com/a/47410394/3929620
  su - www-data
fi

exec "$@"
