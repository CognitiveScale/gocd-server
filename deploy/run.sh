#!/bin/bash
consul-template -config=/consul-template/config.d/gocd-server.json -once
exec /opt/go-server/server.sh
