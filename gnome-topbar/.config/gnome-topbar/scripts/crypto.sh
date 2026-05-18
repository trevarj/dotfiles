#!/bin/sh

if ! command -v curl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

if command -v nm-online >/dev/null 2>&1 && ! nm-online -q -t 2 >/dev/null 2>&1; then
  exit 0
fi

query=$(curl -fsS --max-time 8 -X GET \
  "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=usd,btc" \
  -H "accept: application/json" 2>/dev/null) || exit 0

if [ "${1:-}" = "-d" ]; then
  echo "$query"
  exit
fi

btc=$(printf "%s" "$query" | jq -r 'try (.bitcoin.usd | tonumber) catch empty' 2>/dev/null)
eth=$(printf "%s" "$query" | jq -r 'try (.ethereum.usd | tonumber) catch empty' 2>/dev/null)
ethbtc=$(printf "%s" "$query" | jq -r 'try (.ethereum.btc | tonumber) catch empty' 2>/dev/null)

[ -n "$btc" ] && [ -n "$eth" ] && [ -n "$ethbtc" ] || exit 0

if [ "${1:-}" = "-r" ]; then
  printf " %.0f  %.0f ₿%.3f\n" "$btc" "$eth" "$ethbtc"
else
  printf "%%{T4} %%{T-}%.0f %%{T4} %%{T-}%.0f ₿%.3f\n" "$btc" "$eth" "$ethbtc"
fi
