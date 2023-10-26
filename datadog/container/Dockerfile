FROM ubuntu:20.04

WORKDIR /

RUN apt-get update -y && \
	apt-get install -y gnupg2 apt-transport-https software-properties-common && \
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 33EE313BAD9589B7 &&\
	add-apt-repository 'deb https://apt.datadoghq.com/ stable 7' &&\
	apt-get update -y && apt-get install -y datadog-agent

RUN apt-get install -y python3

RUN apt-get install -y python3-pip

COPY requirements.txt /

RUN pip3 install markupsafe
RUN pip3 install -r requirements.txt

RUN apt-get install -y supervisor

RUN mkdir -p /var/log/supervisor

COPY supervisord-cloud.conf /etc/supervisor/conf.d/supervisord-cloud.conf

COPY supervisord-software.conf /etc/supervisor/conf.d/supervisord-software.conf

COPY datadog_config.py /

COPY type_overrides.conf /

COPY cloud-api-exporter /cloud-api-exporter

COPY start_ddagent.sh /start_ddagent.sh

COPY start_cloud_exporter.sh /start_cloud_exporter.sh

CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord-cloud.conf" ]
