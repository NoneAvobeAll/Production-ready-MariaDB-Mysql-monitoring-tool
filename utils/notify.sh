#!/bin/bash
# Author: Abubakkar
# Send Slack and Telegram notifications (optional)

MESSAGE="$1"

# Send Slack notification
if [ "$ENABLE_SLACK" = true ]; then
    curl -s -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"$MESSAGE\"}" "$SLACK_WEBHOOK_URL"
fi

# Send Telegram notification
if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="$MESSAGE"
fi
