#!/bin/sh

query=$(curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,cardano,crypto-com-chain&vs_currencies=usd" -H "accept: application/json")
btc=$(jq -r ".bitcoin.usd" <<< $query)
eth=$(jq -r ".ethereum.usd" <<< $query)
ada=$(jq -r ".cardano.usd" <<< $query)
cro=$(jq -r '."crypto-com-chain".usd' <<< $query)
printf " %.0f  %.0f  %.2f  %.2f\n" $btc $eth $ada $cro

