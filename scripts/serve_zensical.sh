#!/usr/bin/env zsh

set -euo pipefail

port="8000"

pids=(${(f)$(lsof -tiTCP:${port} -sTCP:LISTEN 2>/dev/null || true)})

if (( ${#pids[@]} > 0 )); then
  echo "Stopping existing listeners on port ${port}:"
  ps -p ${pids[@]} -o pid=,command=
  kill ${pids[@]}

  remaining=(${(f)$(lsof -tiTCP:${port} -sTCP:LISTEN 2>/dev/null || true)})
  if (( ${#remaining[@]} > 0 )); then
    echo "Force stopping listeners still bound to port ${port}:"
    ps -p ${remaining[@]} -o pid=,command=
    kill -9 ${remaining[@]}
  fi
fi

exec zensical serve
