# Build using: docker build -f Dockerfile.gocd-agent -t gocd-agent .
FROM c12e/consul-template:0.18.5
RUN apk --no-cache add bash unzip openjdk8-jre-base git curl openssh jq \
&& SERVER_VER=17.5.0-5095 \
&& curl https://download.gocd.io/binaries/${SERVER_VER}/generic/go-server-${SERVER_VER}.zip  -o /tmp/go-server.zip \
&& mkdir -p /opt \
&& cd /opt \
&& unzip /tmp/go-server.zip \
&& mv /opt/go-server* /opt/go-server \
&& chmod +x  /opt/go-server/server.sh \
&& mkdir -p /opt/go-server/plugins/external \

&& rm -r /tmp/*
Add deploy/run.sh /run.sh
Add deploy/go-server /etc/default/go-server
RUN LAYER=plugins \
  && cd /opt/go-server/plugins/external \
  && wget https://github.com/Vincit/gocd-slack-task/releases/download/v1.3.1/gocd-slack-task-1.3.1.jar \
  && wget https://github.com/gocd-contrib/script-executor-task/releases/download/0.3/script-executor-0.3.0.jar \
  && wget https://github.com/ashwanthkumar/gocd-slack-build-notifier/releases/download/v1.4.0-RC11/gocd-slack-notifier-1.4.0-RC11.jar \
  && wget https://github.com/ashwanthkumar/gocd-build-github-pull-requests/releases/download/v1.3.3/github-pr-poller-1.3.3.jar \
  && wget https://github.com/ashwanthkumar/gocd-build-github-pull-requests/releases/download/v1.3.3/git-fb-poller-1.3.3.jar \
  && wget https://github.com/gocd-contrib/gocd-oauth-login/releases/download/v2.3/github-oauth-login-2.3.jar \
  && wget https://github.com/gocd-contrib/gocd-build-status-notifier/releases/download/1.3/github-pr-status-1.3.jar \
  && wget https://github.com/tomzo/gocd-yaml-config-plugin/releases/download/0.4.0/yaml-config-plugin-0.4.0.jar
ENV JAVA_HOME=/usr/lib/jvm/default-jvm/jre
STOPSIGNAL HUP
WORKDIR /tmp
VOLUME ["/data"]
CMD ["/run.sh"]
