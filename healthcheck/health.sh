#!/bin/bash
exec nohup /usr/bin/java -jar /hc/jetty-runner-9.3.9.v20160517.jar --port 9000 /hc/gocd-health.war > nohup.log || echo false