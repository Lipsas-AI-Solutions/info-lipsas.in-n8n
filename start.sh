#!/bin/sh
echo "Starting Flask API..."
python3 /app/text_extractor_api.py > /tmp/flask.log 2>&1 &
sleep 2
echo "Starting n8n..."
exec n8n start
