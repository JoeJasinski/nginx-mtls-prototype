# Example of Nginx mTLS integration

## About

This serves as a prototype of how you can use Nginx to create an mTLS connection using 
TLS certificates. Nginx can also set a header or headers with information from the client 
cert, such as the Subject or the SAN, such that downstream applications can be assured that
the user making the request is trusted by a common CA.

In this example, we create a CA certificate and key pair. We use this CA to sign client 
and server certificates. The Client certificate has an identity baked into the SAN and is
used by curl to make requests. In this case, the client identity is `spiffe://www.jazstudios.com/joe`. The server certificate is used as a TLS certificate for Nginx. Its  
identity is `spiffe://www.jazstudios.com/server`. The identities are provided in the SAN.

Upon a successful request to the Nginx server, where the client has a valid certificate 
issued by the commonly trusted CA, Nginx will set a bunch of proxy headers that will be 
passed to the proxied app. These headers include the client certificate, the value of 
the client SAN (the identity), and a bunch of other client cert-related headers. 
A downstream app could consume these headers and automatically authenticate the 
request based on the SAN; the app can trust the value of the SAN because 
Nginx validated the cert and SAN at the TCP level through mTLS. 

This example is just a dummy example, so there is no downstream app. However, it 
demonstrates the idea of what is possible. For demonstration purposes, we set the 
TLS headers (client certificate, san, etc) as

This example also uses the ngx_http_js_module to parse and format the SAN from the client
certificate, so the downstream app doesn't need to do this step.

## Why?

This is just an exploration for my own learning. I wanted to create a working example of
this concept. Thanks to all of the resources in the "Sources" section of this README that
helped me create this prototype.

## Requires

- make
- docker
- openssl

## INSTALL AND USE

### Create all the certs

    make certs

## Run Docker with the cert/keys

    make docker

## Curl the docker container

If you issue the following curl, it will respond with a bunch of response headers
with info about the client cert. These are the headers that are also proxied to the
downstream app (if one were configured here.)

This curl will succeed

    curl -k -vvvv \
        --request GET \
        --header "Content-Type: application/json" \
        --cacert root-ca.crt \
        --cert client.crt \
        --key client.key \
        "https://localhost:4443/"

It will contain the following response headers:

    < SSL_Client_San: ["spiffe://www.jazstudios.com/joe"]
    < SSL_Client_Issuer: CN=jazstudios.com
    < SSL_Client: CN=joe2
    < SSL_Client_Verify: SUCCESS

This curl will fail with a 403 Forbidden:

    curl -k -vvvv \
        --request GET \
        --header "Content-Type: application/json" \
        "https://localhost:4443/"

## Sources:

Provided some Nginx config examples that served as the basis for this one

 - https://fardog.io/blog/2017/12/30/client-side-certificate-authentication-with-nginx/
 - https://medium.com/geekculture/mtls-with-nginx-and-nodejs-e3d0980ed950
 - https://serversforhackers.com/c/redirect-http-to-https-nginx


Provided example and code for Nginx javascript extension

- https://raw.githubusercontent.com/xeioex/njs-examples/master/njs/http/certs/js/x509.js

Answered some questions about field in Certs

- https://stackoverflow.com/questions/5795256/what-is-the-difference-between-the-x-509-v3-extensions-basic-constraints-and-key
- https://superuser.com/questions/619008/how-to-properly-setup-openssl-ca-to-generate-ssl-client-certificates
- https://stackoverflow.com/questions/5795256/what-is-the-difference-between-the-x-509-v3-extensions-basic-constraints-and-key
- https://security.stackexchange.com/questions/24106/which-key-usages-are-required-by-each-key-exchange-method
- https://medium.com/@yildirimabdrhm/ssl-certificate-purpose-flag-any-purpose-43f9a6004ad6
- https://www.casesup.com/category/blog/web-services/ssl-certificate-purpose-flag-any-purpose


Misc other articles

- https://medium.com/geekculture/mtls-with-nginx-and-nodejs-e3d0980ed950
- https://smallstep.com/hello-mtls/doc/server/nginx
- https://kulkarniamit.github.io/whatwhyhow/howto/verify-ssl-tls-certificate-signature.html