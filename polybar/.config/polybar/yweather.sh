#!/bin/sh

. "$HOME/.dotenv"

out() {
	printf "%s %d°" "$1" "$temp"
}

if
	res=$(curl -s -X GET \
		-H "Access-Control-Allow-Headers: X-Yandex-API-Key" \
		-H "X-Yandex-API-Key: $YW_API_KEY" \
		"https://api.weather.yandex.ru/v2/informers?lat=$YW_LAT&lon=$YW_LONG")
then
	temp=$(echo "$res" | jq -rn 'try input.fact.temp catch "N/A"')
	condition=$(echo "$res" | jq -rn 'try input.fact.condition catch ""')
	case "$condition" in
	"clear") out "󰖙" ;;
	"partly-cloudy") out "󰖕" ;;
	"cloudy" | "overcast") out "󰖐" ;;
	"drizzle" | "light-rain" | "rain" | "moderate-rain") out "󰖗" ;;
	"showers" | "heavy-rain" | "continuous-heavy-rain") out "󰖖" ;;
	"wet-snow") out "󰙿" ;;
	"light-snow") out "󰖘" ;;
	"snow" | "snow-showers") out "󰼶" ;;
	"hail") out "󰖒" ;;
	"thunderstorm") out "󰖓" ;;
	"thunderstorm-with-rain" | "thunderstorm-with-hail") out "󰙾" ;;
	*) out "-" ;;
	esac
else
	temp="N/A"
	out "-"
fi
