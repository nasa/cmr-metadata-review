#!/bin/bash

create-network() {
    echo creating bridged network
    docker network create cmrdash
}

build() {
    echo building
    docker build -t cmrdash --network cmrdash .
}

start() {
    echo starting
    docker container run --volume `pwd`/../..:/home/cmrdash/cmr-metadata-review:rw --network cmrdash \
	--name cmrdash -p3000:3000 -d cmrdash
}

stop() {
    echo stopping
    docker container stop cmrdash
}

remove() {
    echo removing
    docker rm cmrdash
}

shell() {
    echo attaching to container bash shell
    docker exec -i -t cmrdash /bin/bash -l
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
	echo "Usage: $0 { create-network | build | start | stop | remove | shell }"
	echo
	exit 1
	;;

esac

exit 0

