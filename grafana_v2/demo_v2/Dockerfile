# FROM redislabs/redis:latest
FROM redislabs/redis-internal:7.8.6-13.focal
ADD ./netstat /usr/local/bin/netstat

USER root
RUN chmod +x /usr/local/bin/netstat
USER redislabs