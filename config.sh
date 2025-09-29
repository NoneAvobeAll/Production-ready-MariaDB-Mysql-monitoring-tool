#!/bin/bash
# Author: Abubakkar
# System Admin
# Production DB Monitoring Config

MYSQL_USER="root"
MYSQL_PASS="plc-db"
MYSQL_HOST="192.168.0.10"  # Target MySQL server
MYSQL_PORT=3308            # Target MySQL server port

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
ENABLE_SSH_TUNNEL=true
SSH_USER="sctdev"
SSH_HOST="your_ssh_host"
SSH_PORT=22                # Default SSH port
LOCAL_PORT=3306            # Local port for the tunnel (can be different from MYSQL_PORT)

# Note: MYSQL_PORT is the port of the target MySQL server on the remote host.
# LOCAL_PORT is the local port used for the SSH tunnel to forward to MYSQL_PORT.
