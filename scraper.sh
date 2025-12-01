#!/bin/bash

# MySQL credentials
DB_NAME="bitcoin_db"
TABLE_NAME="bitcoin_price"
USER="root"

# Download the Bitcoin page
curl -s https://www.coindesk.com/price/bitcoin -o btc.html

# Extract the current Bitcoin price
price=$(grep -oE '\$[0-9,]+\.[0-9]+' btc.html | head -1)

# Remove $ and commas to make it numeric
numeric_price=$(echo $price | tr -d '$,')

# Show the numeric price
echo "Current Bitcoin price: $numeric_price"

# Insert into MySQL
/Applications/XAMPP/xamppfiles/bin/mysql -u $USER -e "USE $DB_NAME; INSERT INTO $TABLE_NAME (price) VALUES ($numeric_price);"

echo "Price inserted into MySQL database."

