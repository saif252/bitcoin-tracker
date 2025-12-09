#!/bin/bash

# -----------------------------
# CONFIG
# -----------------------------
URL="https://coinmarketcap.com/currencies/bitcoin/"
DB_USER="root"
DB_PASS=""   # leave empty if XAMPP root has no password
DB_NAME="crypto_db"
ASSET_ID=1
HTML_FILE="btc.html"

# -----------------------------
# DOWNLOAD PAGE
# -----------------------------
curl -s "$URL" > "$HTML_FILE"
echo "Downloaded page to $HTML_FILE"

# -----------------------------
# PARSE DATA
# -----------------------------
# Price
price=$(grep -oE 'Bitcoin price today</strong> is \$[0-9,]+\.[0-9]+' "$HTML_FILE" | head -1 | grep -oE '[0-9,]+\.[0-9]+' | tr -d ',[:space:]')

# 24h Change %
change=$(grep -oE 'Bitcoin is (up|down) [0-9.]+%' "$HTML_FILE" | head -1 | grep -oE '[0-9.]+' | tr -d ',[:space:]')

# Market Cap
market_cap=$(grep -oE 'live market cap of \$[0-9,]+' "$HTML_FILE" | head -1 | grep -oE '[0-9,]+' | tr -d ',[:space:]')

# Volume (24h)
volume_24h=$(grep '<meta property="og:description"' "$HTML_FILE" | head -1 | sed -E 's/.*24-hour trading volume of \$([0-9,]+)\..*/\1/' | tr -d ',')

# Max Supply
max_supply=$(grep -oE 'max. supply of [0-9,]+' "$HTML_FILE" | head -1 | grep -oE '[0-9,]+' | tr -d ',[:space:]')

# Circulating Supply
circ_supply=$(grep -oE 'circulating supply of [0-9,]+' "$HTML_FILE" | head -1 | grep -oE '[0-9,]+' | tr -d ',[:space:]')

# -----------------------------
# CALCULATIONS
# -----------------------------
# FDV
fdv=$(echo "$price * $max_supply" | bc)

# Vol/Mkt Cap %
vol_to_mkt_cap=$(echo "scale=2; ($volume_24h / $market_cap) * 100" | bc)

# -----------------------------
# OUTPUT
# -----------------------------
echo "Price: $price"
echo "Change %: $change"
echo "Market Cap: $market_cap"
echo "Volume (24h): $volume_24h"
echo "FDV: $fdv"
echo "Vol/Mkt Cap (%): $vol_to_mkt_cap"
echo "Circulating Supply: $circ_supply"

# -----------------------------
# INSERT INTO MYSQL
# -----------------------------
mysql -h 127.0.0.1 -P 3306 -u $DB_USER $DB_NAME <<EOF
INSERT INTO asset_metrics
(asset_id, timestamp, price, percent_change_24h, market_cap, volume_24h, fdv, vol_to_mkt_cap, circulating_supply)
VALUES ($ASSET_ID, NOW(), $price, $change, $market_cap, $volume_24h, $fdv, $vol_to_mkt_cap, $circ_supply);
EOF

echo "Data inserted successfully!"
