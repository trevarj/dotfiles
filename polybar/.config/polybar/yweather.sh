#!/bin/sh

. "$HOME/.dotenv"
yweather --lat "$YW_LAT" --long "$YW_LONG" --key ca39a767-93d5-42eb-bf6b-84bb5e815d35 2>/dev/null || echo "N/A"
