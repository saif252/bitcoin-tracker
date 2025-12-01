#!/bin/bash

# MySQL credentials
DB_NAME="bitcoin_db"
TABLE_NAME="bitcoin_price"
USER="root"

# Export data from MySQL to a text file
/Applications/XAMPP/xamppfiles/bin/mysql -u $USER -e "USE $DB_NAME; SELECT date_time, price FROM $TABLE_NAME ORDER BY date_time ASC;" > btc_data.txt

# Remove the header line
tail -n +2 btc_data.txt > btc_data_clean.txt

echo "Data exported to btc_data_clean.txt"

# Generate the plot using gnuplot
gnuplot <<- EOF
    set terminal png size 800,600
    set output 'bitcoin_price.png'
    set title 'Bitcoin Price Over Time'
    set xdata time
    set timefmt "%Y-%m-%d %H:%M:%S"
    set format x "%m-%d\n%H:%M"
    set xlabel 'Date & Time'
    set ylabel 'Price (USD)'
    set grid
    plot 'btc_data_clean.txt' using 1:2 with linespoints title 'Bitcoin Price'
EOF

echo "Plot generated: bitcoin_price.png"

