FROM busybox:ubuntu-14.04

ADD ./currentweather /usr/bin/

EXPOSE 8080

ENTRYPOINT ["currentweather"]