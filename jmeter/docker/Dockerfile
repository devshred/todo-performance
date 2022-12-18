FROM adoptopenjdk/openjdk11:jre

ARG JMETER_VERSION="5.5"
ENV JMETER_HOME /opt/jmeter
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz

RUN    apt-get update \
	&& apt-get -y upgrade \
	&& apt-get -y install curl bash \
	&& rm -rf /var/lib/apt/lists/*

RUN    mkdir -p /tmp/jmeter  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} > /tmp/jmeter/apache-jmeter-${JMETER_VERSION}.tgz  \
	&& mkdir -p /opt  \
	&& tar -xzf /tmp/jmeter/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
	&& mv /opt/apache-jmeter-${JMETER_VERSION} ${JMETER_HOME} \
	&& rm -rf /tmp/jmeter

ENV PATH $PATH:$JMETER_BIN

COPY entrypoint.sh /

WORKDIR	${JMETER_HOME}

ENTRYPOINT ["/entrypoint.sh"]
