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
    curl -H "X-Vault-Token: $VAULT_TOKEN" -X POST \
    -d "{\"common_name\":\"neo4j\",\"alt_names\":\"neo4j.service.consul,$HOSTNAME\",\"ip_sans\":\"127.0.0.1\",\"format\":\"pem\"}" \
    https://${VAULT_ADDR}:8200/v1/pki/issue/c12e-dot-local  > /tmp/certs.json
    mkdir -p  /opt/neo4j/conf/ssl
    jq -r .data.private_key /tmp/certs.json | openssl rsa  -inform PEM -outform DER > /opt/neo4j/conf/ssl/snakeoil.key
    jq -r .data.certificate /tmp/certs.json > /opt/neo4j/conf/ssl/snakeoil.cert
    rm /tmp/certs.json
}
if [ ! -z "${VAULT_ADDR}" ]; then
  echo "Installing keys from ${CERTS_DIR} to /etc/ssl"
  setup_certs

  echo "Installing keys from ${CERTS_DIR} to java"
  setup_certs_java

fi
mkdir -p /data/config /data/logs                                                                                      
ln -s /data/config /etc/go                                                                                            
ln -s /data/logs /var/log/go-server       
consul-template -config=/consul-template/config.d/gocd-server.json -once
exec /opt/go-server/server.sh
