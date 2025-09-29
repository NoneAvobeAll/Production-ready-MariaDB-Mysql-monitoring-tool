#!/bin/bash
# Author: Abubakkar
# Send Slack notification (optional)

MESSAGE="$1"

if [ "$ENABLE_SLACK" = true ]; then
    curl -s -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"$MESSAGE\"}" "$SLACK_WEBHOOK_URL"
fi
