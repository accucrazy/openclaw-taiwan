#!/bin/bash
# Cloud Run entrypoint script
# Creates config file from environment variables and starts the gateway

set -e

# Create config directory
mkdir -p ~/.clawdbot

# Get service account from Secret Manager mounted file
SERVICE_ACCOUNT_FILE=""
if [ -f "/secrets/google-chat-sa/key.json" ]; then
    SERVICE_ACCOUNT_FILE="/secrets/google-chat-sa/key.json"
fi

# Detect Cloud Run service URL (for Google Chat audience)
# Format: https://SERVICE_NAME-PROJECT_NUMBER.REGION.run.app
GOOGLE_CHAT_AUDIENCE="${GOOGLE_CHAT_AUDIENCE:-https://clawdbot-$(gcloud config get-value project 2>/dev/null || echo 'PROJECT').asia-east1.run.app}"

# Build the config file
# Configure Google Chat channel and Gemini as the model provider
if [ -n "$SERVICE_ACCOUNT_FILE" ]; then
    cat > ~/.clawdbot/clawdbot.json << EOF
{
  "plugins": {
    "entries": {
      "googlechat": { "enabled": true },
      "nano-banana": { "enabled": true }
    }
  },
  "channels": {
    "googlechat": {
      "enabled": true,
      "serviceAccountFile": "${SERVICE_ACCOUNT_FILE}",
      "audienceType": "app-url",
      "audience": "${GOOGLE_CHAT_AUDIENCE}/googlechat",
      "webhookPath": "/googlechat",
      "dm": { "policy": "open", "allowFrom": ["*"] },
      "groupPolicy": "open",
      "requireMention": false
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "google/gemini-3-flash-preview"
      }
    }
  }
}
EOF
else
    cat > ~/.clawdbot/clawdbot.json << EOF
{
  "plugins": {
    "entries": {
      "googlechat": { "enabled": true },
      "nano-banana": { "enabled": true }
    }
  },
  "channels": {
    "googlechat": {
      "enabled": true,
      "audienceType": "app-url",
      "audience": "${GOOGLE_CHAT_AUDIENCE}/googlechat",
      "webhookPath": "/googlechat",
      "dm": { "policy": "open", "allowFrom": ["*"] },
      "groupPolicy": "open",
      "requireMention": false
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "google/gemini-3-flash-preview"
      }
    }
  }
}
EOF
fi

echo "Config created at ~/.clawdbot/clawdbot.json"
cat ~/.clawdbot/clawdbot.json

# Start the gateway
exec node dist/index.js gateway --allow-unconfigured --port "${PORT:-8080}" --bind lan

