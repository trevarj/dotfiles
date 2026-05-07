#!/usr/bin/env bash

empty_output() {
  printf '{"text":"","percentage":null}\n'
}

if ! command -v headsetcontrol >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  empty_output
  exit 0
fi

icons=("" "" "" "" "")
len=${#icons[@]}
perc=$((100 / (len - 1)))

if ! output=$(headsetcontrol -o json 2>/dev/null); then
  empty_output
  exit 0
fi

percentage=$(
  printf "%s" "$output" |
    jq -r 'try (([.devices[]?.battery.level? | tonumber? | floor | select(. >= 0)] | first) // empty) catch empty' 2>/dev/null
)

if [[ -z "$percentage" ]]; then
  empty_output
  exit 0
fi

if (( percentage > 100 )); then
  percentage=100
fi

idx=$(((percentage + perc - 1) / perc))
if (( idx >= len )); then
  idx=$((len - 1))
fi
text="󰋎 ${icons[idx]}"

jq -nc \
   --arg text "$text" \
   --argjson percentage "$percentage" \
   '{text: $text, percentage: $percentage}'
