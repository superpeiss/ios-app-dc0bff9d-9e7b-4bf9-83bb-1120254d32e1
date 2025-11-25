#!/bin/bash
# Monitor workflow progress

RUN_ID="$1"
TOKEN="$2"

if [ -z "$RUN_ID" ] || [ -z "$TOKEN" ]; then
    echo "Usage: $0 <run_id> <token>"
    exit 1
fi

echo "Monitoring workflow run ID: $RUN_ID"
echo "URL: https://github.com/superpeiss/ios-app-dc0bff9d-9e7b-4bf9-83bb-1120254d32e1/actions/runs/$RUN_ID"
echo ""

for i in $(seq 1 30); do
  echo "[$i/30] Checking status... ($(date +%H:%M:%S))"

  RESPONSE=$(curl -k -s -X GET \
    "https://api.github.com/repos/superpeiss/ios-app-dc0bff9d-9e7b-4bf9-83bb-1120254d32e1/actions/runs/$RUN_ID" \
    -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github+json")

  STATUS=$(echo "$RESPONSE" | grep -o '"status": *"[^"]*"' | head -1 | sed 's/"status": *"\(.*\)"/\1/')
  CONCLUSION=$(echo "$RESPONSE" | grep -o '"conclusion": *"[^"]*"' | head -1 | sed 's/"conclusion": *"\(.*\)"/\1/')

  echo "  Status: $STATUS, Conclusion: $CONCLUSION"

  if [ "$STATUS" = "completed" ]; then
    echo ""
    if [ "$CONCLUSION" = "success" ]; then
      echo "✅ BUILD SUCCEEDED!"
      exit 0
    else
      echo "❌ BUILD FAILED with conclusion: $CONCLUSION"
      exit 1
    fi
  fi

  if [ $i -lt 30 ]; then
    sleep 20
  fi
done

echo ""
echo "Timeout waiting for workflow to complete"
exit 2
