#!/bin/bash

# icons=("󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
icons=("" "" "" "" "")
len=${#icons[@]}
perc=$((100 / (len - 1)))
if bat=$(headsetcontrol -o json | jq '.devices[].battery.level'); then
  if [ "$bat" -ne -1 ]; then
    idx=$((((bat + perc - 1) / perc) % len))
    printf "󰋎 %s \n" "${icons[idx]}"
  else
    printf ""
  fi
fi
