#!/bin/bash

create-network() {
    docker network create cmrdash
}

build() {
    echo building
    docker build . --network cmrdash -t arcdash/postgres
}

start() {
    echo starting
    docker container run --name postgresql -d \
	--network cmrdash \
	--env POSTGRES_PASSWORD=root \
	--publish 5432:5432 \
	arcdash/postgres
}

stop() {
    echo stopping
    docker container stop postgresql
}

remove() {
    echo removing
    docker rm postgresql
}

shell() {
    echo attaching to container bash shell
    docker exec -i -t postgresql /bin/bash -l
}

case "$1" in
    'create-network')
	create-network
	;;
    'build')
	build
	;;
    'start')
	start
	;;
    'stop')
	stop
	;;
    'remove')
	remove
	;;
    'shell')
	shell
	;;
    *)
	echo
	echo "Usage: $0 { create-network | build | start | stop | remove | shell}"
	echo
	exit 1
	;;

esac

exit 0

