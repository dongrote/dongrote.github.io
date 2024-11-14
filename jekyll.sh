#!/bin/bash

cd $(dirname $(realpath $0))

docker run \
    -it \
    --rm \
    -v .:/srv/jekyll \
    -e JEKYLL_UID=$(id -u) \
    -e JEKYLL_GID=$(id -g) \
    jekyll/jekyll \
    "$@"
