#!/bin/bash

echo "RUN MIGRATIONS"
django-admin migrate

echo "RUN SERVER"
echo "$@"

exec "$@"