
# Bitcoin Tracker

A Bash-based data collection, storage, and visualization system for Bitcoin market data. The system scrapes data from CoinMarketCap, stores it in a MySQL database, and generates graphical plots using Gnuplot.

---

## Quick Start

1. **Import Database:**
```bash
# Using phpMyAdmin or MySQL CLI
mysql -u root -p < crypto_db.sql
```

2. **Run Scraper:**
```bash
bash scraper.sh
```

3. **Generate Plots:**
```bash
bash plot.sh price_24hr
bash plot.sh price_7days
```

> Ensure MySQL paths in `scraper.sh` and `plot.sh` match your system.

---

## Features

- **Automated Data Collection:** Collects Bitcoin price, 24h trading volume, percent change, market capitalization, and circulating supply.
- **Database Storage:** MySQL database (`crypto_db`) with tables `assets` and `asset_metrics`, normalized to 3NF.
- **Visualization:** Generates 10 plots for trend analysis using Gnuplot.
- **Version Control:** Git repository tracks all changes.

---

## Project Structure

```
bitcoin-tracker/
├── scraper.sh         # Bash script to scrape and insert data
├── plot.sh            # Bash script to generate plots
├── crypto_db.sql      # MySQL database dump
├── ERD.pdf            # Entity Relationship Diagram
├── README.md          # Project instructions
├── plots/             # Generated plot images (optional)
└── cron.log           # Sample cron log (optional)
```

---

## Requirements

- **OS:** macOS / Linux  
- **Software:** Bash, MySQL / XAMPP, Gnuplot

---

## Setup Instructions

1. **Import Database:** Import `crypto_db.sql` into MySQL.  
2. **Configure Scripts:** Ensure the MySQL path and credentials are correct in `scraper.sh` and `plot.sh`.  
3. **Run Scraper Manually:**  
```bash
bash scraper.sh
```  
4. **Automate Scraper via Cron (Optional):**  
```cron
0 * * * * /bin/bash "/path/to/scraper.sh" >> "/path/to/cron.log" 2>&1
```  
5. **Generate Plots:**  
```bash
bash plot.sh price_24hr
bash plot.sh price_7days
```  

---

## Fully Diluted Valuation (FDV)

FDV = Price × Maximum Supply (21,000,000 BTC)  

- Calculated dynamically during plotting.  
- Provides insight into potential total market value.  

---

## Script Overview

### scraper.sh
- Downloads Bitcoin HTML page using `curl` with retry mechanism.  
- Extracts metrics using `grep` and `sed`:
  - Price
  - 24-hour trading volume
  - Percent change
  - Market capitalization
  - Circulating supply
- Inserts data into `asset_metrics`.  
- Outputs extracted values for verification.

**Example Output:**
```
Price: 92511.91
Change %: 2.51
Market Cap: 1801365899839
Volume (24h): 67245531351
Circulating Supply: 19961337
Data inserted Successfully
```

### plot.sh
- Queries database and generates plots using Gnuplot.  
- Checks for empty data files to avoid errors.  
- Modular function-based design.

**Available Plots:**
1. Price – Last 24 hours  
2. Price – Last 7 days  
3. Percent change – 24 hours  
4. Market cap / FDV – 7 days  
5. Volume – 24 hours  
6. Circulating supply – 7 days  
7. Market cap – 7 days  
8. Volume / Market cap – 24 hours  
9. Price vs volume / market cap – 24 hours  
10. Market cap vs Price – 7 days  

**Example Usage:**
```bash
bash plot.sh price_24hr
bash plot.sh price_7days
```

---

## Error Handling

- Network failures: retried 3 times before exiting.  
- Parsing failures: script exits if required fields are empty.  
- Database insertion failures: script exits with message.  
- Plotting: checks if query output is empty.

---

## Limitations

- Relies on CoinMarketCap HTML structure; changes may break parsing.  
- Web scraping may be rate-limited.  
- MySQL paths must be configured correctly in scripts.

---

