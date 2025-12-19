#!/usr/bin/env sh

LAT="55.7558"
LONG="37.6173"

res=$(curl -s -X GET \
           "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LONG&current_weather=true&temperature_unit=celsius")

if temp=$(echo "$res" | jq -r '.current_weather.temperature' 2>/dev/null) && [ "$temp" != null ]; then
    temp_rounded=$(printf "%.0f" "$temp")
    if [ "$temp_rounded" -eq 0 ]; then
        temp_rounded=0
    fi
    condition=$(echo "$res" | jq -r '.current_weather.weathercode' 2>/dev/null)
    case "$condition" in
        "0") cond="󰖙" ;;  # Clear sky
        "1") cond="󰖕" ;;  # Partly cloudy
        "2") cond="󰖐" ;;  # Cloudy
        "3") cond="󰖗" ;;  # Light rain
        "4") cond="󰖗" ;;  # Moderate rain
        "5") cond="󰖖" ;;  # Heavy rain
        "6") cond="󰼶" ;;  # Snow
        "7") cond="󰖘" ;;  # Light snow
        "8") cond="󰙾" ;;  # Thunderstorm
        "9") cond="󰖑" ;;  # Fog
        "10") cond="󰖗" ;;  # Drizzle
        "11") cond="󰙿" ;;  # Freezing rain
        "12") cond="󰖒" ;;  # Hail
        "13") cond="󰼸" ;;  # Dust
        "14") cond="󰼸" ;;  # Smoke
        "15") cond="󰼸" ;;  # Ash
        *) cond="" ;;  # Default to no icon
    esac
    printf "%s   %s°C" "$cond" "$temp_rounded"
else
    printf "N/A"
fi
