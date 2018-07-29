#!/bin/bash

systemctl stop apt-daily.service > /dev/null 2>&1
systemctl kill --kill-who=all apt-daily.service > /dev/null 2>&1

# wait until `apt-get updated` has been killed
while ! (systemctl list-units --all apt-daily.service | fgrep -q dead)
do
  sleep 1;
done

killall apt.systemd.daily > /dev/null 2>&1
dpkg --configure -a > /dev/null 2>&1
exit 0