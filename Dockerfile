FROM busybox:ubuntu-14.04

ADD ./currentweather /usr/bin/

ENTRYPOINT ["currentweather"]