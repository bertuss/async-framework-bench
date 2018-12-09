#!/usr/bin/env bash
set -eu
set -o pipefail

# make docker network for bench tests, if it doesn't already exist
if [[ ! -n "$(docker network ls | grep bench)" ]]; then
    docker network create bench
    echo "Docker network created."
fi

# Build docker wrk container
docker build -q -t bench-wrk src/bench/
echo "wrk image built."

NAME="bench-target"
PORT=8000
WAIT_TIME=5

# wrk settings
THREADS=12
CONNECTIONS=400
DURATION=1s
SCRIPT='report.lua'

for image in src/apps/*/*/*.Dockerfile; do
    language=$(echo $image | cut -f3 -d"/")
    framework=$(echo $image | cut -f4 -d"/")
    file=$(echo $image | cut -f5 -d"/")
    dir=$(echo $image | cut -f-4 -d"/")
    type=$(echo $file | cut -f1 -d.)
    tag=bench-${language}-${framework}-${type}

    echo "Buidling image ${tag}"
    docker build -q -t ${tag} -f ${image} ${dir}
    echo "Image built"

    echo "Starting container ${tag}"
    docker run --rm -d --net bench --name ${NAME} ${tag} 
    echo "Running"
    echo "Waiting ${WAIT_TIME} seconds for server to start up..."
    sleep ${WAIT_TIME}

    echo "Starting load test"
    readarray -t LOAD_TEST_RESULT<<<"$(docker run --rm --net bench --name bench-wrk bench-wrk -t${THREADS} -c${CONNECTIONS} -d${DURATION} --latency -s${SCRIPT} http://${NAME}:${PORT})"
    echo "Load test complete"

    echo "----------------"
    echo "${LOAD_TEST_RESULT[@]::${#LOAD_TEST_RESULT[@]}-1}"
    echo "----------------"
    echo "${LOAD_TEST_RESULT[-1]}"

    exit

    echo "Stopping container ${tag}"
    docker kill ${NAME}
    echo "Stopped"
    echo "----------------"
done

# docker kill $(docker ps -aqf 'name=bench')
