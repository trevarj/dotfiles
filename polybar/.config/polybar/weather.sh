#!/bin/sh

. "$HOME/.dotenv"

if
	res=$(curl -s -X GET \
		-H "Access-Control-Allow-Headers: X-Yandex-API-Key" \
		-H "X-Yandex-API-Key: $YW_API_KEY" \
		"https://api.weather.yandex.ru/v2/informers?lat=$YW_LAT&lon=$YW_LONG")
then
	temp=$(echo "$res" | jq -rn 'try input.fact.temp catch ""')
	condition=$(echo "$res" | jq -rn 'try input.fact.condition catch ""')
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
fi

if [ -n "$temp" ]; then
	printf "%s %s°" "$cond" "$temp"
else
	printf "Weather N/A"
fi
