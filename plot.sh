#!/bin/bash

# Config
DB_USER="root"
DB_PASS="" 
DB_NAME="crypto_db"
ASSET_ID=1

# Price Last 24 Hour
price_24hr() {
    TXT_FILE="price_24hr.txt"
    OUTPUT_PNG="price_24hr.png"
    # save Relevent timestamp and prices to price_24hr.txt
    mysql -u "$DB_USER" -h 127.0.0.1 -P 3306 -D "$DB_NAME" -B -N -e "
        SELECT DATE_FORMAT(timestamp,'%Y-%m-%d %H:%i:%s'), price
        FROM asset_metrics
        WHERE asset_id=$ASSET_ID
            AND timestamp >= NOW() - INTERVAL 24 HOUR
        ORDER BY timestamp;
    " > "$TXT_FILE"

    # Check File not empty
    if [[ ! -s "$TXT_FILE" ]]; then
        echo "Error: '$TXT_FILE' is empty. Cannot plot."
        exit 1
    fi

    # Gnuplot
    gnuplot <<-EOF
        set terminal png size 1000,600
        set output "$OUTPUT_PNG"
        set datafile separator "\t"
        set xdata time
        set timefmt "%Y-%m-%d %H:%M:%S"
        set format x "%H:%M"
        set xlabel "Time"
        set ylabel "Price (USD)"
        set title "Bitcoin Price - Last 24 Hours"
        set grid
        plot "$TXT_FILE" using 1:2 with linespoints title "Price" lt rgb "blue" lw 2 pt 7
EOF

    echo "Price (24hr) plot saved to $OUTPUT_PNG"
}

# Price 7 days
price_7days() {
    TXT_FILE="price_7days.txt"
    OUTPUT_PNG="price_7days.png"

    # Query database
    mysql -u "$DB_USER" -h 127.0.0.1 -P 3306 -D "$DB_NAME" -B -N -e "
        SELECT DATE_FORMAT(timestamp,'%Y-%m-%d %H:%i:%s'), price
        FROM asset_metrics
        WHERE asset_id=$ASSET_ID
            AND timestamp >= NOW() - INTERVAL 7 DAY
        ORDER BY timestamp;
    " > "$TXT_FILE"

    if [[ ! -s "$TXT_FILE" ]]; then
        echo "Error: '$TXT_FILE' is empty. Cannot plot."
        exit 1
    fi

    #Gnuplot
    gnuplot <<-EOF
        set terminal png size 1000,600
        set output "$OUTPUT_PNG"
        set datafile separator "\t"
        set xdata time
        set timefmt "%Y-%m-%d %H:%M:%S"
        set format x "%m-%d\n%H:%M"
        set xlabel "Time"
        set ylabel "Price (USD)"
        set title "Bitcoin Price - Last 7 Days"
        set grid
        plot "$TXT_FILE" using 1:2 with linespoints title "Price" lt rgb "green" lw 2 pt 7
EOF

    echo "Price (7 days) plot saved to $OUTPUT_PNG"
}

# Function: Market Cap / FDV Last 7 Days
mcap_fdv() {
    TXT_FILE="mcap_fdv_7days.txt"
    OUTPUT_PNG="mcap_fdv_7days.png"
    MAX_SUPPLY=21000000

    # Query database
    mysql -u "$DB_USER" -h 127.0.0.1 -P 3306 -D "$DB_NAME" -B -N -e "
        SELECT DATE_FORMAT(timestamp,'%Y-%m-%d %H:%i:%s'), market_cap / (price * $MAX_SUPPLY)
        FROM asset_metrics
        WHERE asset_id=$ASSET_ID
            AND timestamp >= NOW() - INTERVAL 7 DAY
        ORDER BY timestamp;
    " > "$TXT_FILE"

    #file not empty
    if [[ ! -s "$TXT_FILE" ]]; then
        echo "Error: '$TXT_FILE' is empty. Cannot plot."
        exit 1
    fi

    #Gnuplot
    gnuplot <<-EOF
        set terminal png size 1000,600
        set output "$OUTPUT_PNG"
        set datafile separator "\t"
        set xdata time
        set timefmt "%Y-%m-%d %H:%M:%S"
        set format x "%d-%m"
        set xlabel "Date"
        set ylabel "Market Cap / FDV"
        set title "Bitcoin Market Cap / FDV - Last 7 Days"
        set grid
        plot "$TXT_FILE" using 1:2 with linespoints title "MCap / FDV" lt rgb "green" lw 2 pt 7
EOF

    echo "Market Cap / FDV (7 days) plot saved to $OUTPUT_PNG"
}

# Function: Volume (24h) vs Time (Last 24 Hours)
volume_24hr() {
    TXT_FILE="volume_24hr.txt"
    OUTPUT_PNG="volume_24hr.png"

    # Query database for last 24 hours
    mysql -u "$DB_USER" -h 127.0.0.1 -P 3306 -D "$DB_NAME" -B -N -e "
        SELECT DATE_FORMAT(timestamp,'%Y-%m-%d %H:%i:%s'), volume_24h
        FROM asset_metrics
        WHERE asset_id=$ASSET_ID
            AND timestamp >= NOW() - INTERVAL 24 HOUR
        ORDER BY timestamp;
    " > "$TXT_FILE"

    #file is not empty
    if [[ ! -s "$TXT_FILE" ]]; then
        echo "Error: '$TXT_FILE' is empty. Cannot plot."
        exit 1
    fi

    # Gnuplot
    gnuplot <<-EOF
        set terminal png size 1000,600
        set output "$OUTPUT_PNG"
        set datafile separator "\t"
        set xdata time
        set timefmt "%Y-%m-%d %H:%M:%S"
        set format x "%H:%M"
        set xlabel "Time"
        set ylabel "Volume (24h)"
        set title "Bitcoin Volume (24h) - Last 24 Hours"
        set grid
        plot "$TXT_FILE" using 1:2 with linespoints title "Volume" lt rgb "orange" lw 2 pt 7
EOF

    echo "Volume (24h) plot saved to $OUTPUT_PNG"
}

# Function: Plot Percent Change 24h vs Time
percent_change_24hr() {
    TXT_FILE="percent_change_24hr.txt"
    OUTPUT_PNG="percent_change_24hr.png"

    # Query timestamp and percent_change_24h
    mysql -u "$DB_USER" -h 127.0.0.1 -P 3306 -D "$DB_NAME" -B -N -e "
        SELECT DATE_FORMAT(timestamp,'%Y-%m-%d %H:%i:%s'), percent_change_24h
        FROM asset_metrics
        WHERE asset_id=$ASSET_ID
            AND timestamp >= NOW() - INTERVAL 24 HOUR
        ORDER BY timestamp;
    " > "$TXT_FILE"

    # Check file not empty
    if [[ ! -s "$TXT_FILE" ]]; then
        echo "Error: '$TXT_FILE' is empty. Cannot plot."
        exit 1
    fi

    #Gnuplot
    gnuplot <<-EOF
        set terminal png size 1000,600
        set output "$OUTPUT_PNG"
        set datafile separator "\t"
        set xdata time
        set timefmt "%Y-%m-%d %H:%M:%S"
        set format x "%H:%M"
        set xlabel "Time"
        set ylabel "24h Price Change (%)"
        set title "Bitcoin 24h Percent Change"
        set grid
        plot "$TXT_FILE" using 1:2 with linespoints title "24h Change" lt rgb "orange" lw 2 pt 7
EOF

    echo "Percent Change (24h) plot saved to $OUTPUT_PNG"
}

# Function: Circulating Supply vs Time (Last 7 Days)
circulating_supply_7days() {
    TXT_FILE="circulating_supply_7days.txt"
    OUTPUT_PNG="circulating_supply_7days.png"

    # Query database
    mysql -u "$DB_USER" -h 127.0.0.1 -P 3306 -D "$DB_NAME" -B -N -e "
        SELECT DATE_FORMAT(timestamp,'%Y-%m-%d %H:%i:%s'), circulating_supply
        FROM asset_metrics
        WHERE asset_id=$ASSET_ID
            AND timestamp >= NOW() - INTERVAL 7 DAY
        ORDER BY timestamp;
    " > "$TXT_FILE"

    #Check file not empty
    if [[ ! -s "$TXT_FILE" ]]; then
        echo "Error: '$TXT_FILE' is empty. Cannot plot."
        exit 1
    fi

    #Gnuplot
    gnuplot <<-EOF
        set terminal png size 1000,600
        set output "$OUTPUT_PNG"
        set datafile separator "\t"
        set xdata time
        set timefmt "%Y-%m-%d %H:%M:%S"
        set format x "%m-%d\n%H:%M"
        set xlabel "Time"
        set ylabel "Circulating Supply"
        set title "Bitcoin Circulating Supply - Last 7 Days"
        set grid
        plot "$TXT_FILE" using 1:2 with linespoints title "Circulating Supply" lt rgb "purple" lw 2 pt 7
EOF

    echo "Circulating Supply (7 days) plot saved to $OUTPUT_PNG"
}

# Main Menu
case "$1" in
    price_24hr)
        price_24hr
        ;;
    price_7days)
        price_7days
        ;;
    percent-change_24hr)
        percent_change_24hr
        ;;
    mcap_fdv)
        mcap_fdv
        ;;
    volume_24hr)
        volume_24hr
        ;;
    circulating_supply)
        circulating_supply_7days
        ;;
    market_cap)
        market_cap_7days
        ;;
    vol_mcap)
        vol_mcap_24hr
        ;;
    price_volume-mcap)
        price_volume-mcap_24hr
        ;;
    mcap_price)
        mcap_price
    ;;
    *)
        echo "Unknown plot type: $1"
        echo "Available types: price_24hr, fdv_7days, percent-change_24hr, mcap-fdv, voume_24hr, circulating_supply, market_cap, vol_mcap, price_volume-mcap, mcap_price"
        exit 1
        ;;
esac
