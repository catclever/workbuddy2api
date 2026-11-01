#!/bin/sh
set -e

GLOBAL_SESSION_PATH="/root/.codebuddy-global-session.json"
DOMESTIC_SESSION_PATH="/root/.codebuddy-session.json"

if [ -n "$SESSION_B64" ]; then
  echo "[workbuddy2api] Materializing session file from SESSION_B64..."
  printf "%s" "$SESSION_B64" | base64 -d > "$GLOBAL_SESSION_PATH"
  cp "$GLOBAL_SESSION_PATH" "$DOMESTIC_SESSION_PATH"
  export SESSION_FILE="${SESSION_FILE:-$GLOBAL_SESSION_PATH}"
elif [ -n "$SESSION_JSON" ]; then
  echo "[workbuddy2api] Materializing session file from SESSION_JSON..."
  printf "%s\n" "$SESSION_JSON" > "$GLOBAL_SESSION_PATH"
  cp "$GLOBAL_SESSION_PATH" "$DOMESTIC_SESSION_PATH"
  export SESSION_FILE="${SESSION_FILE:-$GLOBAL_SESSION_PATH}"
elif [ -f "$GLOBAL_SESSION_PATH" ]; then
  echo "[workbuddy2api] Found mounted session file at $GLOBAL_SESSION_PATH"
  export SESSION_FILE="${SESSION_FILE:-$GLOBAL_SESSION_PATH}"
elif [ -f "$DOMESTIC_SESSION_PATH" ]; then
  echo "[workbuddy2api] Found mounted session file at $DOMESTIC_SESSION_PATH"
  export SESSION_FILE="${SESSION_FILE:-$DOMESTIC_SESSION_PATH}"
else
  echo "[workbuddy2api] WARNING: No SESSION_JSON, SESSION_B64, or mounted session file found!"
fi

exec python3 -u /app/run_proxy.py
