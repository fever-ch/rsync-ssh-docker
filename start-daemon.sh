#!/bin/sh
set -e

if ! [ -f "/etc/ssh-rsync/sshd_config" ]; then
    echo "Missing sshd_config, preparing"
    mkdir -p /etc/ssh-rsync
    sed -e 's/\/etc\/ssh/\/etc\/ssh-rsync/g' < /etc/ssh/sshd_config > /etc/ssh-rsync/sshd_config
    echo -e "PasswordAuthentication no\nHostKey /etc/ssh-rsync/ssh_host_rsa_key\n" >> /etc/ssh-rsync/sshd_config
fi

HOST_KEY="/etc/ssh-rsync/ssh_host_rsa_key"
if ! [ -f "$HOST_KEY" ]; then
    echo "Missing SSH host keys, creating"
    /usr/bin/ssh-keygen -q -t rsa -f $HOST_KEY -C '' -N ''
fi

echo root:$(head -c30 /dev/urandom | base64) | chpasswd

mkdir -p /root/.ssh
echo "# GENERATED entries" > /root/.ssh/authorized_keys

if [ -n "$SSH_PUB_KEYS" ]; then
    IFS=,
    for KEY in $SSH_PUB_KEYS; do
        echo "$KEY" >> /root/.ssh/authorized_keys
    done
fi
chmod -R go-wx /root/.ssh

exec /usr/sbin/sshd -eD -f /etc/ssh-rsync/sshd_config