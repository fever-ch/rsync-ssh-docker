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

EXTENDED_COMPAT="${EXTENDED_COMPAT:-disabled}"

if [ $EXTENDED_COMPAT == "enabled" ]; then
    WRAPPER_PATH="/usr/bin/xrrsync"
else
    WRAPPER_PATH="/usr/bin/rrsync"
fi    

RRSYNC_MODE="${RRSYNC_MODE:-undef}"

if [ $RRSYNC_MODE == "none" ]; then
    RRSYNC_OPT=""
elif [ $RRSYNC_MODE == "ro" ]; then
    RRSYNC_OPT="-ro"
elif [ $RRSYNC_MODE == "rw" ]; then
    RRSYNC_OPT="-rw"
else
    echo "Unspecified rrsync mode, assuming read-only mode"
    RRSYNC_OPT="-ro"    
fi

echo root:$(head -c30 /dev/urandom | base64) | chpasswd

mkdir -p /root/.ssh
echo "# GENERATED entries" > /root/.ssh/authorized_keys

if [ -n "$SSH_PUB_KEYS" ]; then
    IFS=,
    for KEY in $SSH_PUB_KEYS; do
        echo "command=\"$WRAPPER_PATH $RRSYNC_OPT /data\",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding $KEY" >> /root/.ssh/authorized_keys
    done
fi
chmod -R go-wx /root/.ssh

exec /usr/sbin/sshd -eD -f /etc/ssh-rsync/sshd_config