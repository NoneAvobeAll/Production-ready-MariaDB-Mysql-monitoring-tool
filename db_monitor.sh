#!/bin/bash
# Author: Abubakkar
# System Admin
# Production-ready MariaDB 11+ monitoring tool

source ./config.sh
source ./utils/notify.sh

TIMESTAMP=$(date +%F_%H%M%S)
JSON_FILE="$LOG_DIR/db_monitor_$TIMESTAMP.json"
HTML_FILE="$REPORT_DIR/db_monitor_$TIMESTAMP.html"

# ---------------------------
# Setup SSH Tunnel (if enabled)
# ---------------------------
if [ "$ENABLE_SSH_TUNNEL" = true ]; then
    echo "Setting up SSH tunnel..."
    ssh -f -N -L $LOCAL_PORT:$MYSQL_HOST:$MYSQL_PORT $SSH_USER@$SSH_HOST -p $SSH_PORT
    if [ $? -ne 0 ]; then
        echo "Error: Failed to establish SSH tunnel. Exiting."
        exit 1
    fi
    MYSQL_HOST="127.0.0.1"  # Redirect to local tunnel
    MYSQL_PORT="$LOCAL_PORT"
    echo "SSH tunnel established: localhost:$LOCAL_PORT -> $MYSQL_HOST:$MYSQL_PORT"
fi

# ---------------------------
# Verify MySQL Connectivity
# ---------------------------
echo "Verifying MySQL connectivity..."
mysql -u$MYSQL_USER -p$MYSQL_PASS -h$MYSQL_HOST -P$MYSQL_PORT -e "SELECT 1;" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Unable to connect to MySQL. Check your credentials and connection settings. Exiting."
    exit 1
fi

# ---------------------------
# Collect global status
# ---------------------------
TMP_STATS=$(mysql -u$MYSQL_USER -p$MYSQL_PASS -h$MYSQL_HOST -P$MYSQL_PORT -sN -e "
SHOW GLOBAL STATUS LIKE 'Created_tmp%';
SHOW VARIABLES LIKE 'tmp_table_size';
")
TMP_DISK=$(echo "$TMP_STATS" | awk '/Created_tmp_disk_tables/ {print $2}')

# ---------------------------
# Collect top memory-consuming threads
# ---------------------------
TOP_MEMORY=$(mysql -u$MYSQL_USER -p$MYSQL_PASS -h$MYSQL_HOST -P$MYSQL_PORT -sN -e "
SELECT THREAD_ID, EVENT_NAME, CURRENT_NUMBER_OF_BYTES_USED/1024/1024 AS memory_mb
FROM performance_schema.memory_summary_by_thread_by_event_name
WHERE CURRENT_NUMBER_OF_BYTES_USED > 0
ORDER BY memory_mb DESC
LIMIT 20;
")

# ---------------------------
# Collect long-running queries
# ---------------------------
LONG_QUERIES=$(mysql -u$MYSQL_USER -p$MYSQL_PASS -h$MYSQL_HOST -P$MYSQL_PORT -sN -e "
SELECT ID, USER, HOST, DB, TIME, COMMAND, STATE, INFO
FROM information_schema.PROCESSLIST
WHERE COMMAND != 'Sleep' AND TIME > $LONG_QUERY_THRESHOLD
ORDER BY TIME DESC;
")

# ---------------------------
# Collect InnoDB buffer pool stats
# ---------------------------
BUFFER_POOL=$(mysql -u$MYSQL_USER -p$MYSQL_PASS -h$MYSQL_HOST -P$MYSQL_PORT -sN -e "
SELECT POOL_ID, POOL_SIZE, FREE_BUFFERS, DATABASE_PAGES, OLD_DATABASE_PAGES,
       MODIFIED_DB_PAGES, PENDING_READS, PENDING_WRITES, PAGE_HITS
FROM information_schema.INNODB_BUFFER_POOL_STATS;
")

# ---------------------------
# Collect locks & waits
# ---------------------------
LOCKS=$(mysql -u$MYSQL_USER -p$MYSQL_PASS -h$MYSQL_HOST -P$MYSQL_PORT -sN -e "
SELECT r.trx_id AS waiting_trx_id,
       r.trx_mysql_thread_id AS waiting_thread,
       r.trx_started AS waiting_started,
       r.trx_query AS waiting_query,
       b.trx_id AS blocking_trx_id,
       b.trx_mysql_thread_id AS blocking_thread,
       b.trx_started AS blocking_started,
       b.trx_query AS blocking_query
FROM information_schema.innodb_lock_waits w
JOIN information_schema.innodb_trx r ON w.requesting_trx_id = r.trx_id
JOIN information_schema.innodb_trx b ON w.blocking_trx_id = b.trx_id;
")

# ---------------------------
# Generate JSON report
# ---------------------------
jq -n \
  --arg ts "$TIMESTAMP" \
  --arg tmpdisk "$TMP_DISK" \
  --argjson topmem "$(echo "$TOP_MEMORY" | jq -R -s -c 'split("\n") | map(select(length>0))')" \
  --argjson longq "$(echo "$LONG_QUERIES" | jq -R -s -c 'split("\n") | map(select(length>0))')" \
  --argjson buffer "$(echo "$BUFFER_POOL" | jq -R -s -c 'split("\n") | map(select(length>0))')" \
  --argjson locks "$(echo "$LOCKS" | jq -R -s -c 'split("\n") | map(select(length>0))')" \
  '{
    timestamp: $ts,
    tmp_disk_tables: $tmpdisk,
    top_memory_threads: $topmem,
    long_running_queries: $longq,
    buffer_pool_stats: $buffer,
    transaction_locks: $locks
  }' > $JSON_FILE

# ---------------------------
# Generate HTML report
# ---------------------------
cat <<EOF > $HTML_FILE
<html>
<head>
    <title>MariaDB Monitor Report - $TIMESTAMP</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            line-height: 1.6;
        }
        h2 {
            color: #2c3e50;
        }
        h3 {
            color: #34495e;
            border-bottom: 1px solid #ecf0f1;
            padding-bottom: 5px;
        }
        pre {
            background: #ecf0f1;
            padding: 10px;
            border-radius: 5px;
            overflow-x: auto;
        }
        p {
            color: #7f8c8d;
        }
        .alert {
            color: #e74c3c;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <h2>MariaDB Monitor Report</h2>
    <p><b>Time:</b> $TIMESTAMP</p>

    <h3>Temp Tables Spilled to Disk:</h3>
    <p class="alert">$TMP_DISK</p>

    <h3>Top Memory-Consuming Threads:</h3>
    <pre>$TOP_MEMORY</pre>

    <h3>Long-Running Queries:</h3>
    <pre>$LONG_QUERIES</pre>

    <h3>InnoDB Buffer Pool Stats:</h3>
    <pre>$BUFFER_POOL</pre>

    <h3>Transaction Locks & Waits:</h3>
    <pre>$LOCKS</pre>
</body>
</html>
EOF

# ---------------------------
# Alerts
# ---------------------------
if (( TMP_DISK > TMP_DISK_THRESHOLD )); then
    MSG="⚠ ALERT: $TMP_DISK temp tables spilled to disk!"
    echo $MSG
    ./utils/notify.sh "$MSG"
fi

# High-memory threads alert
while read -r thread memory; do
    mem_int=${memory%.*}
    if (( mem_int > HIGH_MEMORY_THRESHOLD_MB )); then
        MSG="⚠ ALERT: Thread $thread using $memory MB memory!"
        echo $MSG
        ./utils/notify.sh "$MSG"
    fi
done < <(echo "$TOP_MEMORY" | awk '{print $1, $3}')
