#!/bin/sh
t=0
sleep_pid=0

toggle() {
    t=$(((t + 1) % 2))

    if [ "$sleep_pid" -ne 0 ]; then
        kill $sleep_pid >/dev/null 2>&1
    fi
}


trap "toggle" USR1

while true; do
    if [ $t -eq 0 ]; then
        echo ""
    else
		HK=$(TZ='Asia/Hong_Kong' date +'%-H:%M')
		NY=$(TZ='America/New_York' date +'%-H:%M')
		echo "$HK HK $NY NY"
    fi
    sleep 1 &
    sleep_pid=$!
    wait
done
