#!/bin/sh

# icons=("󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
icons=("" "" "" "" "")
len=${#icons[@]}
if bat=$(arctis7-controls battery); then
  bat="${bat#Battery level: *}"
  bat="${bat%*%}"
  if [ $bat -ne 0 ]; then
    idx=$(( $bat % ($len + 1) ))
    echo "󰋎 ${icons[idx]}"
  fi
fi
