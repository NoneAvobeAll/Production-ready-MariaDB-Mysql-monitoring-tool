#!/bin/bash
# Author: Abubakkar
# System Admin
# Production DB Monitoring Config

MYSQL_USER="monitor"
MYSQL_PASS="YOUR_MONITOR_PASSWORD"
MYSQL_HOST="localhost"
MYSQL_PORT=3306

LOG_DIR="/var/log/db_monitor"
REPORT_DIR="/var/www/html/db_monitor_reports"
mkdir -p "$LOG_DIR" "$REPORT_DIR"

# Thresholds
TMP_DISK_THRESHOLD=100          # Temp tables spilled to disk
LONG_QUERY_THRESHOLD=300        # Seconds
HIGH_MEMORY_THRESHOLD_MB=1024   # Per-thread memory

# Alerts
ENABLE_SLACK=false
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/XXXX/XXXX/XXXX"
