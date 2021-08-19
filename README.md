
### Create the root CA Cert (self-signed)

    ./scripts/create_root.sh 

### Create a client key and CSR

    ./scripts/create_client.sh 

### Create a server key and CSR

    ./scripts/create_client.sh 

## Run Docker with the cert/keys

    docker run -it \
        -p 8000:80 \
        -p 4443:443 \
        -v `pwd`/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
        -v `pwd`/server.crt:/srv/server.crt:ro \
        -v `pwd`/server.key:/srv/server.key:ro \
        -v `pwd`/root-ca.crt:/srv/root-ca.crt:ro nginx 

## Curl the docker container

    curl -k -vvvv \
    --request GET \
    --header "Content-Type: application/json" \
    --cacert root-ca.crt \
    --cert client.crt \
    --key client.key \
    "https://localhost:4443/"