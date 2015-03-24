#!/bin/bash
docker build --rm -t graphite .
# save docker image as tar archive
docker save -o graphite.tar graphite
# compress the archive
gzip -f graphite.tar
