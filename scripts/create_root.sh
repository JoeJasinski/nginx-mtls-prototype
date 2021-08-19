#!/bin/sh
set -x

openssl req \
    -newkey rsa:4096 \
    -x509 \
    -sha256 \
    -keyout root-ca.key \
    -out root-ca.crt \
    -days 6000 \
    -nodes \
    -subj "/CN=jazstudios.com"

openssl x509 -in root-ca.crt -text -noout -purpose
