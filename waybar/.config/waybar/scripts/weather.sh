#!/usr/bin/env sh

LAT="55.7558"
LONG="37.6173"

res=$(curl -s -X GET \
           "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LONG&current_weather=true&temperature_unit=celsius")

if temp=$(echo "$res" | jq -r '.current_weather.temperature' 2>/dev/null) && [ "$temp" -z ]; then
    temp_rounded=$(printf "%.0f" "$temp")
    if [ "$temp_rounded" -eq 0 ]; then
        temp_rounded=0
    fi
    condition=$(echo "$res" | jq -r '.current_weather.weathercode' 2>/dev/null)
    case "$condition" in
        0) cond="󰖙" ;;
        1|2) cond="󰖕" ;;
        3) cond="󰖐" ;;
        45|48) cond="󰖑" ;;
        51|53|55) cond="󰖗" ;;
        56|57) cond="󰖒" ;;
        61|63|65) cond="󰖗" ;;
        66|67) cond="󰖒" ;;
        71|73|75|77) cond="󰼶" ;;
        80|81|82) cond="󰖖" ;;
        85|86) cond="󰼶" ;;
        95|96|99) cond="󰙾" ;;
        *) cond="󰨹" ;;
    esac
    printf "%s   %s°C" "$cond" "$temp_rounded"
else
    printf "󰨹 "
fi
