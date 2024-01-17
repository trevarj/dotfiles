#!/bin/sh

# icons=("󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
icons=("" "" "" "" "")
len=${#icons[@]}
perc=$(( 100 / ($len - 1) ))
if bat=$(arctis7-controls battery); then
  bat="${bat#Battery level: *}"
  bat="${bat%*%}"
  if [ $bat -ne 0 ]; then
    idx=$(( (($bat + $perc - 1) / $perc) % $len ))
    echo "󰋎 ${icons[idx]}"
  else 
    echo ""
  fi
fi
