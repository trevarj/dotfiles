#!/bin/sh

query=$(curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,cardano,crypto-com-chain&vs_currencies=usd" -H "accept: application/json")

if [ "$1" = "-d" ]; then
    echo "$query"
    exit;
fi

btc=$(echo "$query" | jq -rn 'try input.bitcoin.usd catch "0"')
eth=$(echo "$query" | jq -rn 'try input.ethereum.usd catch "0"')
ada=$(echo "$query" | jq -rn 'try input.cardano.usd catch "0"')
cro=$(echo "$query" | jq -rn 'try input."crypto-com-chain".usd catch 0')
printf "%%{T4} %%{T-}%.0f %%{T4} %%{T-}%.0f %%{T4} %%{T-}%.2f %%{T4} %%{T-}%.2f\n" "$btc" "$eth" "$ada" "$cro"

