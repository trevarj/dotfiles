#!/usr/bin/env sh
set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 4 ]; then
  printf 'Usage: %s <pattern> [path] [type] [max-depth]\n' "$0" >&2
  exit 2
fi

pattern=$1
path=${2:-.}
type_filter=${3:-}
max_depth=${4:-}

set -- fd --glob --color never
if [ -n "$type_filter" ]; then
  set -- "$@" --type "$type_filter"
fi
if [ -n "$max_depth" ]; then
  set -- "$@" --max-depth "$max_depth"
fi
"$@" "$pattern" "$path"
