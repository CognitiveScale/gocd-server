# Build using: docker build -f Dockerfile.gocd-agent -t gocd-agent .
FROM c12e/consul-template:0.14.0
RUN apk --no-cache add bash unzip openjdk8-jre-base git curl openssh jq \
&& SERVER_VER=16.3.0-3183 \
&& curl https://download.go.cd/binaries/${SERVER_VER}/generic/go-server-${SERVER_VER}.zip  -o /tmp/go-server.zip \
&& mkdir -p /opt \
&& cd /opt \
&& unzip /tmp/go-server.zip \
&& mv /opt/go-server* /opt/go-server \
&& chmod +x  /opt/go-server/server.sh \
&& rm -r /tmp/*

Add deploy/run.sh /run.sh
Add deploy/go-server /etc/default/go-server
RUN LAYER=plugins \
  && mkdir -p /opt/go-server/plugins/external \
  && cd /opt/go-server/plugins/external \
  && wget https://github.com/Vincit/gocd-slack-task/releases/download/v1.2/gocd-slack-task-1.2.jar \
  && wget https://github.com/gocd-contrib/script-executor-task/releases/download/0.2/script-executor-0.2.jar \
  && wget https://github.com/ashwanthkumar/gocd-slack-build-notifier/releases/download/v1.2.1/gocd-slack-notifier-1.2.1.jar \
  && wget https://github.com/ashwanthkumar/gocd-build-github-pull-requests/releases/download/v1.2.4/github-pr-poller-1.2.4.jar \
  && wget https://github.com/ashwanthkumar/gocd-build-github-pull-requests/releases/download/v1.2.4/git-fb-poller-1.2.4.jar \
  && wget https://github.com/gocd-contrib/gocd-oauth-login/releases/download/v1.2/github-oauth-login-1.2.jar \
  && wget https://github.com/gocd-contrib/gocd-build-status-notifier/releases/download/1.1/github-pr-status-1.1.jar

ENV JAVA_HOME=/usr/lib/jvm/default-jvm/jre
STOPSIGNAL HUP
WORKDIR /tmp
VOLUME ["/data"]
CMD ["/run.sh"]
