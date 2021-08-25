#!/bin/sh
set -x


echo "Create Client pkcs12 File from cert and key"
openssl pkcs12 -export -nodes \
    -certfile root-ca.crt \
    -inkey client.key \
    -in client.crt \
    -passout pass: \
    -out client.p12
