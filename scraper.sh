#!/bin/bash

# Configuration
URL="https://coinmarketcap.com/currencies/bitcoin/"
DB_USER="root"
DB_PASS=""   #empty as XAMPP has no password
DB_NAME="crypto_db"
ASSET_ID=1
HTML_FILE="btc.html"


# Downloading Page
MAX_RETRIES=3
count=0
# Loop for trying trying multiple times if the page couldnt be downloaded
while [ $count -lt $MAX_RETRIES ]; 
do
    curl -s "$URL" -o "$HTML_FILE"
    if [ $? -eq 0 ] && [ -s "$HTML_FILE" ]; 
    then
        break
    fi
    echo "Download failed. Retrying... ($((count+1))/$MAX_RETRIES)"
    sleep 5
    ((count++))
done

# Even if after 3 tries the page couldnt be downloaded then prints error message and exits
if [ $count -eq $MAX_RETRIES ]; 
then
    echo "Error: Failed to download page after $MAX_RETRIES attempts."
    exit 1
fi

echo "Downloaded page to $HTML_FILE"


# Parsing relevent data
# Price
price=$(grep -oE 'Bitcoin price today</strong> is \$[0-9,]+\.[0-9]+' "$HTML_FILE" | head -1 | grep -oE '[0-9,]+\.[0-9]+' | tr -d ',[:space:]')

# 24h Change %
raw=$(grep -oE 'Bitcoin is (up|down) [0-9.]+%' "$HTML_FILE" | head -1)

direction=$(echo "$raw" | grep -oE 'up|down')
value=$(echo "$raw" | grep -oE '[0-9.]+' | tr -d ',[:space:]')

if [[ "$direction" == "down" ]]; then
    change="-$value"
else
    change="$value"
fi


# Market Cap
market_cap=$(grep -oE 'live market cap of \$[0-9,]+' "$HTML_FILE" | head -1 | grep -oE '[0-9,]+' | tr -d ',[:space:]')

# Volume (24h)
volume_24h=$(grep '<meta property="og:description"' "$HTML_FILE" | head -1 | sed -E 's/.*24-hour trading volume of \$([0-9,]+)\..*/\1/' | tr -d ',')

# Circulating Supply
circ_supply=$(grep -oE 'circulating supply of [0-9,]+' "$HTML_FILE" | head -1 | grep -oE '[0-9,]+' | tr -d ',[:space:]')


# CHeck if the parsed data is correct
if [ -z "$price" ] || [ -z "$market_cap" ] || [ -z "$volume_24h" ]; then
    echo "Error: Failed to parse required data. Website structure may have changed or blocked scraping."
    exit 1
fi


# Display Scraped Data
echo "Price: $price"
echo "Change %: $change"
echo "Market Cap: $market_cap"
echo "Volume (24h): $volume_24h"
echo "Circulating Supply: $circ_supply"

# Insert data into sql
mysql -h 127.0.0.1 -P 3306 -u $DB_USER $DB_NAME <<EOF
INSERT INTO asset_metrics
(asset_id, timestamp, price, percent_change_24h, market_cap, volume_24h, circulating_supply)
VALUES ($ASSET_ID, NOW(), $price, $change, $market_cap, $volume_24h, $circ_supply);
EOF


# data couldnt be inserted then exits and prints error message
if [ $? -ne 0 ]; then
    echo "Error: Failed to insert data into MySQL."
    exit 1
fi

echo "Data inserted successfully!"
