#!/bin/bash
# Author: Abubakkar
# System Admin
# Production DB Monitoring Config

MYSQL_USER="root"
MYSQL_PASS="plc-db"
MYSQL_HOST="192.168.0.10"
MYSQL_PORT=3306

LOG_DIR="/home/abubakkar/Desktop/Scrap/mysqlStatus/logs"
REPORT_DIR="/home/abubakkar/Desktop/Scrap/mysqlStatus/db_monitor_reports"
mkdir -p "$LOG_DIR" "$REPORT_DIR"

# Thresholds
TMP_DISK_THRESHOLD=100          # Temp tables spilled to disk
LONG_QUERY_THRESHOLD=300        # Seconds
HIGH_MEMORY_THRESHOLD_MB=1024   # Per-thread memory

# Alerts
ENABLE_SLACK=false
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/XXXX/XXXX/XXXX"

# Telegram Bot Configuration
TELEGRAM_BOT_TOKEN="YOUR_TELEGRAM_BOT_TOKEN"
TELEGRAM_CHAT_ID="YOUR_TELEGRAM_CHAT_ID"

# SSH Tunneling Configuration
ENABLE_SSH_TUNNEL=false
SSH_USER="your_ssh_user"
SSH_HOST="your_ssh_host"
LOCAL_PORT=3307  # Local port for the tunnel
