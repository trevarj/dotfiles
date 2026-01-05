#!/bin/sh

while ! nm-online -q; do
    sleep 1
done

query=$(curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=usd,btc" -H "accept: application/json")

if [ "$1" = "-d" ]; then
  echo "$query"
  exit
fi

btc=$(echo "$query" | jq -rn 'try input.bitcoin.usd catch "0"')
eth=$(echo "$query" | jq -rn 'try input.ethereum.usd catch "0"')
ethbtc=$(echo "$query" | jq -rn 'try input.ethereum.btc catch "0"')

if [ "$1" = "-r" ]; then
  printf " %.0f  %.0f ₿%.3f\n" "$btc" "$eth" "$ethbtc"
else
  printf "%%{T4} %%{T-}%.0f %%{T4} %%{T-}%.0f ₿%.3f\n" "$btc" "$eth" "$ethbtc"
fi
