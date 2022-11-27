#!/bin/bash

timezones=(
    'America/Los_Angeles'
    'America/New_York'
    'Europe/London'
    'Europe/Paris'
    'Asia/Hong_Kong'
    'Australia/Sydney'
)
date_fmt='%-H:%M'

printf "\e[32;1m[%s] \e[0m" "$(date +"$date_fmt")" # our time
for tz in "${timezones[@]}"
do
    printf "[%s %s] " "$(echo "$tz" | sed -e 's/.*\///;s/_/ /' )" "$(TZ=$tz date +"$date_fmt")"
done
printf "\n"