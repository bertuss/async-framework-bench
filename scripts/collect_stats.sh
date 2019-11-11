#!/usr/bin/env bash
set -efu
set -o pipefail

trap "exit" INT TERM ERR
trap "sed -i.bak -e 's/[^[:print:]\t]//g' -e 's/^\[2J\[H//g' output/stats.jsonl" EXIT

docker stats --format "{\"container\": {\"id\": \"{{ .ID }}\", \"name\": \"{{ .Name }}\"}, \"statistics\": {\"cpu_percentage\": \"{{ .CPUPerc }}\", \"memory_percentage\": \"{{ .MemPerc }}\", \"memory_usage\": \"{{ .MemUsage }}\", \"network_io\": \"{{ .NetIO }}\", \"block_io\": \"{{ .BlockIO }}\", \"pids\": \"{{ .PIDs }}\"}}" >>output/stats.jsonl
