#!/bin/sh

. "$HOME/.dotenv"

temp="N/A"
if
	res=$(curl -s -X GET \
		-H "Access-Control-Allow-Headers: X-Yandex-API-Key" \
		-H "X-Yandex-API-Key: $YW_API_KEY" \
		"https://api.weather.yandex.ru/v2/informers?lat=$YW_LAT&lon=$YW_LONG")
then
	temp=$(echo "$res" | jq -r 'try input.fact.temp catch "N/A"')
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

printf "%s %s" "$cond" "$temp"
