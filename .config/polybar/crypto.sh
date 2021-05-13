#!/bin/sh

query=$(curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=ethereum,cardano&vs_currencies=usd" -H "accept: application/json")
eth=$(jq -r ".ethereum.usd" <<< $query)
ada=$(jq -r ".cardano.usd" <<< $query)
printf "ETH %.0f ADA %.2f\n" $eth $ada

