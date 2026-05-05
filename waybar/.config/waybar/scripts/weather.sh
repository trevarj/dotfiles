#!/usr/bin/env sh

LAT="0.0"
LONG="0.0"

UNIT_FILE="/tmp/waybar-weather-unit"
[ -f "$UNIT_FILE" ] && UNIT=$(cat "$UNIT_FILE") || UNIT="C"

if [ "$UNIT" = "F" ]; then
    UNIT_PARAM="fahrenheit"
    UNIT_SYMBOL="°F"
else
    UNIT_PARAM="celsius"
    UNIT_SYMBOL="°C"
fi

while ! nm-online -q; do
    sleep 1
done

res=$(curl -s -X GET \
           "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LONG&current_weather=true&temperature_unit=$UNIT_PARAM")

if temp=$(echo "$res" | jq -r '.current_weather.temperature' 2>/dev/null) && [[ -n "$temp" ]]; then
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
    printf "%s   %s%s" "$cond" "$temp_rounded" "$UNIT_SYMBOL"
else
    printf "󰨹 "
fi
