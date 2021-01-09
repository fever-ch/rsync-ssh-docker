FROM alpine:3.12

RUN apk add -U  \
    openssh-server \
    rsync && \
    rm -f /var/cache/apk/*

RUN mkdir /data    

ADD start-daemon.sh /
RUN chmod +x start-daemon.sh

EXPOSE 22

ENTRYPOINT ["/start-daemon.sh"]
