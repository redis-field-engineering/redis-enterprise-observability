FROM redislabs/redis:latest
ADD ./netstat /usr/local/bin/netstat

USER root
RUN chmod +x /usr/local/bin/netstat
USER redislabs