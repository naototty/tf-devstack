#!/bin/bash

if [[ `whoami` !=  'stack' ]]; then
   echo "This script must be run by user 'stack'"
   exit 1
fi

if [ -f ~/rhel-account.rc ]; then
   source ~/rhel-account.rc
else
   echo "File ~/rhel-account not found"
   exit
fi

if [ -f ~/env.sh ]; then
   source ~/env.sh
else
   echo "File ~/env.sh not found"
   exit
fi

my_file="$(readlink -e "$0")"
my_dir="$(dirname $my_file)"


mkdir -p /home/stack/.ssh
chmod 700 /home/stack/.ssh
# Generate key-pair
ssh-keygen -b 2048 -t rsa -f /tmp/sshkey -q -N ""

# ssh config to do not check host keys and avoid garbadge in known hosts files
cat <<EOF >/home/stack/.ssh/config
Host *
StrictHostKeyChecking no
UserKnownHostsFile=/dev/null
EOF
chown stack:stack /home/stack/.ssh/config
chmod 644 /home/stack/.ssh/config

cd $my_dir
cat undercloud.conf.template | envsubst >/home/stack/undercloud.conf

openstack undercloud install

#Adding stack to group docker
sudo usermod -a -G docker stack

echo User 'stack' has been added to group 'docker'. Please relogin


