#!/bin/sh

# icons=("󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
icons=("" "" "" "" "")
len=${#icons}
if bat=$(arctis7-controls battery); then
	bat="${bat#Battery level: *}"
	bat="${bat%*%}"
  idx=$(( $bat % $len ))
	echo "󰋎 ${icons[idx]}"
fi
