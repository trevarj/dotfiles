#!/bin/sh

query=$(curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,cardano,crypto-com-chain&vs_currencies=usd" -H "accept: application/json")

if [ "$1" = "-d" ]; then
    echo "$query"
    exit;
fi

btc=$(jq -rn 'try input.bitcoin.usd catch "0"' <<< $query)
eth=$(jq -rn 'try input.ethereum.usd catch "0"' <<< $query)
ada=$(jq -rn 'try input.cardano.usd catch "0"' <<< $query)
cro=$(jq -rn 'try input."crypto-com-chain".usd catch 0' <<< $query)
printf " %.0f  %.0f  %.2f  %.2f\n" $btc $eth $ada $cro

