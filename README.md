# RSync SSH Docker

Docker image that provides _SSH_ and _rsync over SSH_ access to volumes. Authentication relies on SSH public keys that are provided as environment variables to the container.

This image aims to be used to create container endpoints in a backup infrastructure, which might act as an entry-point to retrieve the data to be saved, or in the other direction, to write down the backups.

It can be used as a target or a source for tools which use _rsync_ to build incremental backups. 
[Rsync time backup](https://github.com/laurent22/rsync-time-backup) is a full-fledged backup script which includes features such that incremental backups, the purge of old backups with a customizable strategy.

## Usage

### Environment variable

- `SSH_PUB_KEYS`: List of comma-separated SSH public keys.

### Volume mounts

- `/etc/ssh-rsync`: path used to persist the host SSH (it is auto-generated if not present, i.e. on the first run).
- `/data`: path used to read or write.
    

### Example

On the server side:

    docker run -d --name rsync-ssh-access 
        -v folder-to-be-rsynced:/data:ro \ 
        -v conf:/etc/ssh-rsync \ 
        -e SSH_PUB_KEYS="ssh-rsa AAAAB.../MsggyE= root@bkupdaemon" \
        -p 2222:22 fever-ch/rsync-ssh

On the client side:

    rsync -avzH --numeric-ids -e 'ssh -p 2222' root@server:/data/ backup-directory/

---

2021 Raphaël P. Barazzutti - fever.ch