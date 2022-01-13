#!/bin/sh
set -x


echo "Create Server CSR Config File"

cat << EOF > server.csr.conf
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
default_bits = 4092
prompt = no

[req_distinguished_name]
CN = server

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
URI = spiffe://www.jazstudios.com/server
EOF

echo "Create Server CSR File"

openssl req \
    -newkey rsa:4096 \
    -keyout server.key \
    -out server.csr \
    -nodes \
    -days 30 \
    -config server.csr.conf

echo "View CSR"
openssl req -text -noout -verify -in server.csr 


echo "Create Server Cert Config File"

# We need to set the "serverAuth", to set the "Certificate purpose" to
# SSL server : Yes
# The alt_names contain our identity for the server

cat << EOF > server.crt.conf
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
default_bits = 4092
prompt = no

[req_distinguished_name]
CN = server

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
URI = spiffe://www.jazstudios.com/server
EOF


echo "Create Server CRT File"

openssl x509 \
    -req \
    -sha256 \
    -extensions v3_req \
    -in server.csr \
    -out server.crt \
    -CA root-ca.crt \
    -CAkey root-ca.key \
    -CAcreateserial \
    -extfile server.crt.conf \
    -days 6000


echo "View Cert"
# View Cert
openssl x509 -in server.crt -text -noout -purpose

echo "Verify Cert matches Key"

# verify key and modlus of cert and key
openssl x509 -noout -modulus -in server.crt| openssl md5
openssl rsa -noout -modulus -in server.key| openssl md5

echo "Verify CA created Cert"

# verify CA issued the cert
openssl verify -verbose -CAfile root-ca.crt  server.crt 