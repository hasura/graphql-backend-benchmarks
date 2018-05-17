#!/usr/bin/env sh

set -e

usage() {
    echo "Usage: $0 (mysql|pg) (init|start|nuke)"
}

if [ "$#" -ne 2 ]; then
    usage
    exit 1
fi

SCRIPT_DIR=$(dirname "$0")
DOCKER_COMPOSE_FILE="$SCRIPT_DIR/docker-compose-$1.yml"

init() {
    mkdir -p /tmp/prisma
    npm install prisma --prefix=/tmp/prisma
    PRISMA=/tmp/prisma/node_modules/prisma/dist/index.js
    docker-compose -f "$DOCKER_COMPOSE_FILE" up -d
    # Needs a better way
    echo "waiting for the containers to be up and running"
    sleep 30
    (cd "$SCRIPT_DIR"; "$PRISMA" deploy)
    (cd "$SCRIPT_DIR"; "$PRISMA" import --data chinook.zip)
}

case $2 in
    init)
        init
        exit
        ;;
    start)
        docker-compose -f "$DOCKER_COMPOSE_FILE" up -d
        exit
        ;;
    stop)
        docker-compose -f "$DOCKER_COMPOSE_FILE" stop
        exit
        ;;
    nuke)
        docker-compose -f "$DOCKER_COMPOSE_FILE" stop
        docker-compose -f "$DOCKER_COMPOSE_FILE" rm -f
        exit
        ;;
    *)
        echo "unexpected option: $1"
        usage
        exit 1
        ;;
esac
