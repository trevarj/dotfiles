#!/bin/sh

if bat=$(arctis7-controls battery);
then
        bat="${bat#Battery level: *}"
        bat="${bat%*%}"
        # bat=$(echo "$bat" | awk '{print $3}' | tr -d %)
        if [ $bat -eq 0 ]; then
                echo ""
        elif [ $bat -le 10 ]; then
                echo " "
        elif [ $bat -le 25 ]; then
                echo " "
        elif [ $bat -le 50 ]; then
                echo " "
        elif [ $bat -le 75 ]; then
                echo " "
        else
                echo " "
        fi
fi
