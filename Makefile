DOCKER_NETWORK ?= "jjj-nginx-mtls"


.PHONY: root client server docker clean

root:
	./scripts/create_root.sh


client:
	./scripts/create_client.sh


server: 
	./scripts/create_server.sh


pkcs12:
	./scripts/create_pkcs12.sh


certs: root server client pkcs12



clean:
	rm client.* server.* root-ca.*


run:
	docker-compose up --build
