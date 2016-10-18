#!/bin/bash
CERTS_DIR=/cscerts
setup_certs() {
  if [ -f "${CERTS_DIR}/ca.cert.pem" ]; then
    cp ${CERTS_DIR}/*.cert.pem /usr/local/share/ca-certificates
    update-ca-certificates
  else
    echo "${CERTS_DIR} NOT FOUND certificates not installed to /etc/ssl !!!"
  fi
}
setup_certs_java() {
  if [ -f "${CERTS_DIR}/ca-chain.cert.pem" ]; then
  keytool -import \
    -storepass changeit -noprompt \
    -keystore /usr/lib/jvm/default-jvm/jre/lib/security/cacerts \
    --alias cs_key_chain -file ${CERTS_DIR}/ca-chain.cert.pem
  else
    echo "${CERTS_DIR}/ca-chain.cert.pem NOT FOUND certificates not installed !!!"
  fi
}
get_certs_vault() {
    CRT_FILE=$1
    KEY_FILE=$2
    curl -H "X-Vault-Token: $VAULT_TOKEN" -X POST \
    -d "{\"common_name\":\"neo4j\",\"alt_names\":\"neo4j.service.consul,$HOSTNAME\",\"ip_sans\":\"127.0.0.1\",\"format\":\"pem\"}" \
    ${VAULT_ADDR}/v1/pki/issue/c12e-dot-local  > /tmp/certs.json
    mkdir -p  /opt/neo4j/conf/ssl
    jq -r .data.private_key /tmp/certs.json > $KEY_FILE
    jq -r .data.certificate /tmp/certs.json > $CRT_KEY
}
get_secrets() {
    cd /
    curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET \
    ${VAULT_ADDR}/v1/secret/gocd\
      | jq -r .data.rootfs\
      | base64 -d\
      | tar xz
    [ ! -f /root/.ssh/known_host ] && ssh-keyscan github.com >> /root/.ssh/known_hosts \
        && ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts
}

wait_for() {
  local proto="$(echo $1 | grep :// | sed -e's,^\(.*://\).*,\1,g')"
  local url="$(echo ${1/$proto/})"
  local user="$(echo $url | grep @ | cut -d@ -f1)"
  host_port="$(echo ${url/$user@/} | cut -d/ -f1)"
  host=$(echo $host_port | cut -d: -f1)
  port=$(echo $host_port | cut -d: -f2)
  echo "Waiting for ${host} on ${port}"
  while ! nc -z ${host} ${port} &> /dev/null; do
    sleep 1
    echo -n "."
  done
}
if [ ! -z "${VAULT_ADDR}" ]; then
  wait_for "$VAULT_ADDR"
  echo "Installing keys from ${CERTS_DIR} to /etc/ssl"
  setup_certs

  echo "Installing keys from ${CERTS_DIR} to java"
  setup_certs_java

  get_certs_vault /tmp/cert.pem /tmp/key.pem
  get_secrets
fi

# symlink persistent data from /data 
for dir in /opt/go-server/artifacts /opt/go-server/dba /opt/go-server/db /etc/go /var/log/go-server;
do
  data_dir=/data/$(basename $dir)
  mkdir -p $data_dir

  if [ ! -e $dir ] && [ -d $data_dir ]; 
  then
    ln -s $data_dir $dir
  fi
done 

exec /opt/go-server/server.sh
