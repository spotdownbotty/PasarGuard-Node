#!/bin/sh
set -e

mkdir -p /app/certs

if [ ! -f /app/certs/ssl_cert.pem ] || [ ! -f /app/certs/ssl_key.pem ]; then

echo "Generating self signed certificate..."

cat > /tmp/san.cnf <<EOF
[req]
distinguished_name=req_distinguished_name
x509_extensions=v3_req
prompt=no

[req_distinguished_name]
CN=${NODE_DOMAIN}

[v3_req]
subjectAltName=@alt_names

[alt_names]
DNS.1=${NODE_DOMAIN}
DNS.2=localhost
IP.1=127.0.0.1
EOF


openssl req \
-x509 \
-newkey ec \
-pkeyopt ec_paramgen_curve:P-256 \
-nodes \
-days 3650 \
-keyout /app/certs/ssl_key.pem \
-out /app/certs/ssl_cert.pem \
-config /tmp/san.cnf \
-extensions v3_req


fi


export SSL_CERT_FILE=/app/certs/ssl_cert.pem
export SSL_KEY_FILE=/app/certs/ssl_key.pem

echo "Starting PasarGuard Node..."

exec /app/main
