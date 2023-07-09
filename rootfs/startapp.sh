#!/usr/bin/env bash

grant_video_permissions() {
  local username="app"

  local files
  files=$(find /dev/dri /dev/dvb /dev/vchiq /dev/vc-mem /dev/video1? -type c -print 2>/dev/null)

  local i video_gid video_name
  for i in $files
  do
    video_gid=$(stat -c '%g' "$i")
    if ! id -G "$username" | grep -qw "$video_gid"
    then
      video_name=$(getent group "${video_gid}" | awk -F: '{print $1}')
      if [[ -z "${video_name}" ]]
      then
        video_name="video$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c8)"
        sudo groupadd "$video_name"
        sudo groupmod -g "$video_gid" "$video_name"
      fi

      echo "Granting access to ${i} to ${username} via group ${video_name}"
      sudo usermod -a -G "$video_name" "$username"

      if [[ $(stat -c '%A' "${i}" | cut -b 5,6) != "rw" ]]
      then
          echo -e "**** The device ${i} does not have group read/write permissions, which might prevent hardware transcode from functioning correctly. To fix it, you can run the following on your docker host: ****\nsudo chmod g+rw ${i}\n"
      fi
    fi
  done
}

stalonetray &

export HOME=/config
# export QT_QPA_PLATFORM=xcb

grant_video_permissions

exec obs "$@"
