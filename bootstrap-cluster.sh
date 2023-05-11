#!/usr/bin/env bash

set -eux

exit 0

export PATH=/root/bin:$PATH

mkdir /root/bin
CEPHADM="/root/bin/cephadm"
curl --silent --output $CEPHADM --location https://github.com/ceph/ceph/raw/quincy/src/cephadm/cephadm
chmod a+x $CEPHADM

mkdir -p /etc/ceph
mon_ip=$(hostname -I)

bootstrap_extra_options='--allow-fqdn-hostname --dashboard-password-noupdate'

$CEPHADM bootstrap --mon-ip $mon_ip --initial-dashboard-password {{ admin_password }} ${bootstrap_extra_options}

fsid=$(cat /etc/ceph/ceph.conf | grep fsid | awk '{ print $3}')
cephadm_shell="$CEPHADM shell --fsid ${fsid} -c /etc/ceph/ceph.conf -k /etc/ceph/ceph.client.admin.keyring"

{% for number in range(1, nodes) %}
  ssh-copy-id -f -i /etc/ceph/ceph.pub  -o StrictHostKeyChecking=no root@192.168.122.$[100 + {{ number }}]
{% endfor %}
