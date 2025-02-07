#!/bin/sh

. "$HOME/.dotenv"

USER="$GH_ACCT"
TOKEN="$GH_TOKEN"

notifications=$(echo "user = \"$USER:$TOKEN\"" | curl -sf -K- https://api.github.com/notifications | jq ".[].unread" | grep -c true)

if [ "$notifications" -gt 0 ]; then
  echo " $notifications  "
else
  echo ""
fi
