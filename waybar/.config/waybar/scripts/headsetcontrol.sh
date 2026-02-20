#!/usr/bin/env bash

icons=("" "" "" "" "")
len=${#icons[@]}
perc=$((100 / (len - 1)))
text=""
percentage=""

if percentage=$(headsetcontrol -o json | jq '.devices[].battery.level'); then
  if [ "$percentage" -ne -1 ]; then
      idx=$((((percentage + perc - 1) / perc) % len))
      text="󰋎 ${icons[idx]}"
  fi
fi

jq -nc \
   --arg text "$text" \
   --argjson percentage "$percentage" \
   '{text: $text, percentage: $percentage}'
