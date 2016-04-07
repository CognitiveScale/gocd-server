# Build using: docker build -f Dockerfile.gocd-agent -t gocd-agent .
FROM c12e/consul-template:0.14.0
Add deploy/run.sh /run.sh
Add deploy/*.ctmpl  /consul-template/templates/
Add deploy/gocd-server.json /consul-template/config.d/gocd-server.json
RUN apk --no-cache add bash unzip openjdk8-jre-base git curl openssh jq \
&& SERVER_VER=16.3.0-3183 \
&& curl https://download.go.cd/binaries/${SERVER_VER}/generic/go-server-${SERVER_VER}.zip  -o /tmp/go-server.zip \
&& mkdir -p /opt \
&& cd /opt \
&& unzip /tmp/go-server.zip \
&& mv /opt/go-server* /opt/go-server \
&& chmod +x  /opt/go-server/server.sh \
&& rm -r /tmp/*
ENV JAVA_HOME=/usr/lib/jvm/default-jvm/jre
WORKDIR /tmp
VOLUME ["/data"]
CMD ["/run.sh"]
