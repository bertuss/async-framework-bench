#!/usr/bin/env bash
set -eu
set -o pipefail

# trap to kill any sub-processes
trap "exit" INT TERM ERR
trap "kill 0" EXIT

# constants
SCRIPTS_DIR=$(dirname "$(python3 -c "import os; print(os.path.realpath('$0'))")")
BASE_DIR=$(dirname "${SCRIPTS_DIR}")

# settings
TARGET_NAME="bench-target"
NETWORK_NAME="bench-network"
BENCH_NAME="bench-wrk"
PORT=8000
WAIT_TIME=5

# wrk settings
THREADS=12
CONNECTIONS=400
DURATION=30s
SCRIPT='report.lua'

# make docker network for bench tests, if it doesn't already exist
if [[ ! -n "$(docker network ls | grep ${NETWORK_NAME})" ]]; then
    docker network create ${NETWORK_NAME}
    echo "Docker network created."
fi

# Build docker wrk container
docker build -q -t bench-wrk src/bench/
echo "wrk image built."

# Cleanup
docker kill ${TARGET_NAME} 2>/dev/null || true

# Loop through all dockerfiles
# Build, start container, bench, kill container
for image in src/apps/*/*/*.Dockerfile; do
    language=$(echo ${image} | cut -f3 -d"/")
    framework=$(echo ${image} | cut -f4 -d"/")
    file=$(echo ${image} | cut -f5 -d"/")
    dir=$(echo ${image} | cut -f-4 -d"/")
    type=$(echo ${file} | cut -f1 -d.)
    tag=bench-${language}-${framework}-${type}

    echo "----------------"
    echo "Buidling image ${tag}"
    docker build -q -t ${tag} -f ${image} ${dir}
    echo "Image built"

    echo "----------------"
    echo "Starting container ${tag}"
    docker run --rm -d --net ${NETWORK_NAME} --name ${TARGET_NAME} ${tag} &
    BENCH_PID=$!
    echo "Running"

    echo "Collecting statistics from docker"
    ${SCRIPTS_DIR}/collect_stats.sh &
    STATS_PID=$!
    echo "Statistics pid: ${STATS_PID}"

    echo "Waiting ${WAIT_TIME} seconds for server to start up..."
    sleep ${WAIT_TIME}

    echo "----------------"
    echo "Starting load test"
    readarray -t LOAD_TEST_RESULT<<<"$(docker run --rm --net ${NETWORK_NAME} --name ${BENCH_NAME} ${BENCH_NAME} -t${THREADS} -c${CONNECTIONS} -d${DURATION} --latency -s${SCRIPT} http://${TARGET_NAME}:${PORT})"
    echo "Load test complete"

    echo "----------------"
    echo "${LOAD_TEST_RESULT[-1]}" >> bar.json

    echo "----------------"
    echo "Stopping container ${tag}"
    docker kill ${TARGET_NAME}
    echo "Stopped"
    echo "----------------"
done


# Cleanup
docker kill ${TARGET_NAME} 2>/dev/null || true
