#!/bin/bash

#django-admin runserver 0.0.0.0:8000

PROJECT_NAME="mtls_django"
SITE_DIR="/src/mtls_django"
CONNECT_METHOD="http"
NUM_PROCS=1
NUM_THREADS=1

uwsgi --chdir ${SITE_DIR}/ \
    --module=${PROJECT_NAME}.wsgi:application \
    --master \
    --env DJANGO_SETTINGS_MODULE=${PROJECT_NAME}.settings \
    --vacuum \
    --log-master \
    --max-requests=5000 \
    --buffer-size=32768 \
    --${CONNECT_METHOD:=socket} 0.0.0.0:8000 \
    --processes ${NUM_PROCS} \
    --threads ${NUM_THREADS} \
    --python-autoreload=1 \
    --honour-stdin
