#!/bin/bash

# shellcheck disable=SC1091

set -e
#set -o errexit
#set -o nounset
#set -o pipefail
#set -o xtrace # Uncomment this line for debugging purpose


FILE=/docker-entrypoint.sh
if [ -f "$FILE" ]; then
  . $FILE;
fi


#https://jtreminio.com/blog/running-docker-containers-as-current-host-user/#ok-so-what-actually-works
if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then
  userdel -f daemon;
  if getent group daemon; then
      groupdel daemon;
  fi
  groupadd -g ${GROUP_ID} daemon;
  useradd -l -u ${USER_ID} -g daemon daemon;
  install -d -m 0755 -o daemon -g daemon /home/daemon;
  #chown --changes --silent --no-dereference --recursive --from=33:33 ${USER_ID}:${GROUP_ID}
  #    /home/daemon
  #    /.composer
  #    /var/run/php-fpm
  #    /var/lib/php/sessions
  #;
fi


exec "$@"
