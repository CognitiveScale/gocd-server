FROM gocd/gocd-server:v18.1.0

RUN mkdir -p /godata/plugins/external

RUN LAYER=plugins \
  && cd /godata/plugins/external \
  && wget https://github.com/Vincit/gocd-slack-task/releases/download/v1.3.1/gocd-slack-task-1.3.1.jar \
  && wget https://github.com/gocd-contrib/script-executor-task/releases/download/0.3/script-executor-0.3.0.jar \
  && wget https://github.com/ashwanthkumar/gocd-slack-build-notifier/releases/download/v1.4.0-RC10/gocd-slack-notifier-1.4.0-RC10.jar \
  && wget https://github.com/gocd-contrib/gocd-oauth-login/releases/download/v2.4/github-oauth-login-2.4.jar \
  && wget https://github.com/ashwanthkumar/gocd-build-github-pull-requests/releases/download/v1.3.4/github-pr-poller-1.3.4.jar \
  && wget https://github.com/ashwanthkumar/gocd-build-github-pull-requests/releases/download/v1.3.4/git-fb-poller-1.3.4.jar \
  && wget https://github.com/gocd-contrib/gocd-build-status-notifier/releases/download/1.4/github-pr-status-1.4.jar \
  && wget https://github.com/tomzo/gocd-yaml-config-plugin/releases/download/0.6.0/yaml-config-plugin-0.6.0.jar
ENV JAVA_HOME=/usr/lib/jvm/default-jvm/jre
STOPSIGNAL HUP
VOLUME ["/godata"]
