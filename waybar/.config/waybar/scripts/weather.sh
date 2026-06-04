#!/usr/bin/env sh

LAT="${TREV_WEATHER_LATITUDE:-}"
LONG="${TREV_WEATHER_LONGITUDE:-}"
FALLBACK_ICON="󰨹"

UNIT_FILE="/tmp/waybar-weather-unit"
UNIT="C"
if [ -r "$UNIT_FILE" ]; then
    UNIT=$(cat "$UNIT_FILE" 2>/dev/null || printf "C")
fi

if [ "$UNIT" = "F" ]; then
    UNIT_PARAM="fahrenheit"
    UNIT_SYMBOL="°F"
else
    UNIT_PARAM="celsius"
    UNIT_SYMBOL="°C"
fi

fallback() {
    printf "%s\n" "$FALLBACK_ICON"
    exit 0
}

if ! command -v curl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
    fallback
fi

if [ -z "$LAT" ] || [ -z "$LONG" ]; then
    fallback
fi

if command -v nm-online >/dev/null 2>&1 && ! nm-online -q -t 2 >/dev/null 2>&1; then
    fallback
fi

res=$(curl -fsS --max-time 8 -X GET \
          "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LONG&current_weather=true&temperature_unit=$UNIT_PARAM" \
          2>/dev/null) || fallback

temp_rounded=$(printf "%s" "$res" |
    jq -r 'try (.current_weather.temperature | tonumber | round | tostring) catch empty' 2>/dev/null) || fallback
[ -n "$temp_rounded" ] || fallback

condition=$(printf "%s" "$res" |
    jq -r 'try (.current_weather.weathercode | tostring) catch empty' 2>/dev/null)

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
    *) cond="$FALLBACK_ICON" ;;
esac

printf "%s   %s%s\n" "$cond" "$temp_rounded" "$UNIT_SYMBOL"
