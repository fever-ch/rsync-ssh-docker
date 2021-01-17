FROM alpine:3.12

RUN apk add -U  \
    openssh-server \
    rsync \
    rrsync && \
    rm -f /var/cache/apk/*

RUN mkdir /data    

ADD start-daemon.sh /
ADD xrrsync /usr/bin/xrrsync

RUN chmod +x start-daemon.sh /usr/bin/xrrsync

VOLUME [ "/etc/ssh-rsync", "/data" ]

EXPOSE 22

ENTRYPOINT ["/start-daemon.sh"]
