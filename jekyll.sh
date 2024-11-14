#!/bin/bash

cd $(dirname $(realpath $0))

docker run \
    -it \
    --rm \
    -p 4000:4000 \
    -v .:/srv/jekyll \
    -e JEKYLL_UID=$(id -u) \
    -e JEKYLL_GID=$(id -g) \
    jekyll/jekyll \
    "$@"
