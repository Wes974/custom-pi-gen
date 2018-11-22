#!/bin/bash -e

on_chroot << EOF
  curl -s https://bootstrap.pypa.io/get-pip.py | python

  git clone https://github.com/Screenly/screenly-ose.git /home/pi/screenly
  cd /home/pi/screenly
  git checkout production

  pip install -r requirements.txt
  mkdir -p /etc/ansible
  echo -e "[local]\nlocalhost ansible_connection=local" | tee /etc/ansible/hosts > /dev/null

  cd ansible
  HOME=/home/pi ansible-playbook site.yml --skip-tags enable-ssl,disable-nginx,touches_boot_partition
  chown -R pi:pi /home/pi/screenly

  apt-get autoclean
  apt-get clean

  find /usr/share/doc -depth -type f ! -name copyright -delete
  find /usr/share/doc -empty -delete
  rm -rf /usr/share/man /usr/share/groff /usr/share/info /usr/share/lintian /usr/share/linda /var/cache/man
  find /usr/share/locale -type f ! -name 'en' ! -name 'de*' ! -name 'es*' ! -name 'ja*' ! -name 'fr*' ! -name 'zh*' -delete
  find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'en*' ! -name 'de*' ! -name 'es*' ! -name 'ja*' ! -name 'fr*' ! -name 'zh*' -exec rm -r {} \;

  HOME=/home/pi python /home/pi/screenly/server.py &
  sleep 5
  /home/pi/screenly/bin/prepare_device_for_imaging.sh
  pkill -f server.py
  sleep 5

EOF
