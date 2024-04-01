#!/bin/sh

# shellcheck source=/dev/null
. "$HOME/.dotenv"

res=$(curl -s -X GET \
	-H "Access-Control-Allow-Headers: X-Yandex-API-Key" \
	-H "X-Yandex-API-Key: $YW_API_KEY" \
	"https://api.weather.yandex.ru/v2/informers?lat=$YW_LAT&lon=$YW_LONG")

if
	temp=$(echo "$res" | jq -r '.fact.temp' 2>/dev/null)
	[ "$temp" != null ]
then
	condition=$(echo "$res" | jq -r '.fact.condition')
	case "$condition" in
	"clear") cond="󰖙" ;;
	"partly-cloudy") cond="󰖕" ;;
	"cloudy" | "overcast") cond="󰖐" ;;
	"drizzle" | "light-rain" | "rain" | "moderate-rain") cond="󰖗" ;;
	"showers" | "heavy-rain" | "continuous-heavy-rain") cond="󰖖" ;;
	"wet-snow") cond="󰙿" ;;
	"light-snow") cond="󰖘" ;;
	"snow" | "snow-showers") cond="󰼶" ;;
	"hail") cond="󰖒" ;;
	"thunderstorm") cond="󰖓" ;;
	"thunderstorm-with-rain" | "thunderstorm-with-hail") cond="󰙾" ;;
	*) cond="" ;;
	esac
	printf "%s %s°" "$cond" "$temp"
else
	printf "N/A"
fi
