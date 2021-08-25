#!/bin/sh
set -x


cat << EOF > root-ca.crt.conf
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
default_bits = 4092
prompt = no

[req_distinguished_name]
CN = www.jazstudios.com

[v3_req]
basicConstraints = critical,CA:true
keyUsage = critical, keyEncipherment, dataEncipherment, digitalSignature, cRLSign, keyCertSign

extendedKeyUsage = clientAuth, serverAuth
subjectAltName = @alt_names
[alt_names]
URI = spiffe://www.jazstudios.com/
EOF


echo "Generate Root CA"
openssl req \
    -newkey rsa:4096 \
    -x509 \
    -sha256 \
    -extensions v3_req \
    -keyout root-ca.key \
    -out root-ca.crt \
    -days 6000 \
    -nodes \
    -config root-ca.crt.conf \
    -subj "/CN=jazstudios.com"


echo "View root cert"
openssl x509 -in root-ca.crt -text -noout -purpose
