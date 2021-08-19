#!/bin/sh
set -x


echo "Create Client CSR Config File"

cat << EOF > client.csr.conf
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
default_bits = 4092
prompt = no

[req_distinguished_name]
CN = joe2

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
URI = spiffe://www.jazstudios.com/joe
EOF

echo "Create Client CSR File"

openssl req \
    -newkey rsa:4096 \
    -keyout client.key \
    -out client.csr \
    -nodes \
    -days 30 \
    -config client.csr.conf

echo "View CSR"
openssl req -text -noout -verify -in client.csr 


echo "Create Client Cert Config File"

cat << EOF > client.crt.conf
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
default_bits = 4092
prompt = no

[req_distinguished_name]
CN = joe

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
URI = spiffe://www.jazstudios.com/joe
EOF


echo "Create Client CSR File"

openssl x509 \
    -req \
    -sha256 \
    -extensions v3_req \
    -in client.csr \
    -out client.crt \
    -CA root-ca.crt \
    -CAkey root-ca.key \
    -CAcreateserial \
    -extfile client.crt.conf \
    -days 6000


echo "View Cert"
# View Cert
openssl x509 -in client.crt -text -noout

echo "Verify Cert matches Key"

# verify key and modlus of cert and key
openssl x509 -noout -modulus -in client.crt| openssl md5
openssl rsa -noout -modulus -in client.key| openssl md5

echo "Verify CA created Cert"

# verify CA issued the cert
openssl verify -verbose -CAfile root-ca.crt  client.crt
