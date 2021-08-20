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

run:
	docker-compose up --build

