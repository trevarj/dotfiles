#!/usr/bin/env sh
set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
  printf 'Usage: %s <pattern> [path] [include-glob]\n' "$0" >&2
  exit 2
fi

pattern=$1
path=${2:-.}
include=${3:-}

if [ -n "$include" ]; then
  rg --line-number --no-heading --color never --sort modified --glob "$include" -- "$pattern" "$path"
else
  rg --line-number --no-heading --color never --sort modified -- "$pattern" "$path"
fi
