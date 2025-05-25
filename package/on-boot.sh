#!/bin/sh
set -e

if [ -x "$(which ubnt-device-info)" ]; then
  OS_VERSION="${FW_VERSION:-$(ubnt-device-info firmware_detail | grep -oE '^[0-9]+')}"
elif [ -f "/usr/lib/version" ]; then
  # UNASPRO == Unas Pro
  # example /usr/lib/version file contents:
  # UNASPRO.al324.v4.2.9.3ec2ce6.250417.1324
  if [ "$(grep -c '^UCKP.*\.v[0-9]\.' /usr/lib/version)" = '1' ]; then
    OS_VERSION="$(sed -e 's/UCKP.*.v\(.\)\..*/\1/' /usr/lib/version)"
  elif [ "$(grep -c '^UCKG2.*\.v[0-9]\.' /usr/lib/version)" = '1' ]; then
    OS_VERSION="$(sed -e 's/UCKG2.*.v\(.\)\..*/\1/' /usr/lib/version)"
  elif [ "$(grep -c '^UNASPRO.*\.v[0-9]\.' /usr/lib/version)" = '1' ]; then
    OS_VERSION="$(sed -e 's/UNASPRO.*.v\(.\)\..*/\1/' /usr/lib/version)"  
  else
    echo "Could not detect OS Version.  /usr/lib/version contains:"
    cat /usr/lib/version
    exit 1
  fi
else
  echo "Could not detect OS Version.  No ubnt-device-info, no version file."
  exit 1
fi


if [ "$OS_VERSION" = '1' ]; then
  TAILSCALE_ROOT="/mnt/data/tailscale"
else
  TAILSCALE_ROOT="/data/tailscale"
fi

$TAILSCALE_ROOT/manage.sh on-boot
