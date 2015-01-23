FROM busybox:ubuntu-14.04

ADD ./release/linux-amd64/currentweather /usr/bin/

ENTRYPOINT ["currentweather"]