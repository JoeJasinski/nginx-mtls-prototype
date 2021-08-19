DOCKER_NETWORK ?= "jjj-nginx-mtls"


.PHONY: root client server docker clean

root:
	./scripts/create_root.sh


client:
	./scripts/create_client.sh


server: 
	./scripts/create_server.sh


certs: root server client


clean:
	rm client.* server.* root-ca.*

docker:
	docker network create ${DOCKER_NETWORK} || true
	docker run -it \
        -p 8000:80 \
        -p 4443:443 \
        --network=${DOCKER_NETWORK} \
        -v `pwd`/nginx/njs/:/etc/nginx/njs/ \
        -v `pwd`/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
        -v `pwd`/server.crt:/srv/server.crt:ro \
        -v `pwd`/server.key:/srv/server.key:ro \
        -v `pwd`/root-ca.crt:/srv/root-ca.crt:ro nginx \

