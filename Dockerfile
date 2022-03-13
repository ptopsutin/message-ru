FROM ubuntu:21.10
ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN useradd -u 1001 -ms /bin/bash stop-putin

RUN apt-get update && \
	apt-get install -y curl csvkit geoip-bin

COPY . /home/stop-putin/
RUN chown -R stop-putin /home/stop-putin/files/
WORKDIR /home/stop-putin/

VOLUME /home/stop-putin/files

USER stop-putin

ENTRYPOINT ["/home/stop-putin/start.sh"]
CMD ["--mode=http"]