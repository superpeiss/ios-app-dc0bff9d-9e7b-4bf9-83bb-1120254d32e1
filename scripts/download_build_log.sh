#!/bin/bash
# Script to download build log from GitHub Actions

set -e

GITHUB_TOKEN="$1"
OWNER="$2"
REPO="$3"
RUN_ID="$4"

if [ -z "$GITHUB_TOKEN" ] || [ -z "$OWNER" ] || [ -z "$REPO" ]; then
    echo "Usage: $0 <github_token> <owner> <repo> [run_id]"
    exit 1
fi

if [ -z "$RUN_ID" ]; then
    echo "Fetching latest run ID..."
    RESPONSE=$(curl -k -s -X GET \
      "https://api.github.com/repos/$OWNER/$REPO/actions/runs?per_page=1" \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github+json" \
      -H "X-GitHub-Api-Version: 2022-11-28")

    RUN_ID=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data['workflow_runs'][0]['id'] if 'workflow_runs' in data and len(data['workflow_runs']) > 0 else '')" 2>/dev/null)

    if [ -z "$RUN_ID" ]; then
        echo "❌ No workflow runs found"
        exit 1
    fi
fi

echo "Downloading artifacts for run ID: $RUN_ID"

# Get artifacts for the run
ARTIFACTS_RESPONSE=$(curl -k -s -X GET \
  "https://api.github.com/repos/$OWNER/$REPO/actions/runs/$RUN_ID/artifacts" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28")

# Find build-log artifact
ARTIFACT_ID=$(echo "$ARTIFACTS_RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if 'artifacts' in data:
    for artifact in data['artifacts']:
        if artifact.get('name') == 'build-log':
            print(artifact['id'])
            break
" 2>/dev/null)

if [ -z "$ARTIFACT_ID" ]; then
    echo "❌ Build log artifact not found"
    echo "Run may still be in progress or no artifacts were uploaded"
    exit 1
fi

echo "Downloading build log artifact: $ARTIFACT_ID"

# Download artifact
curl -k -L -X GET \
  "https://api.github.com/repos/$OWNER/$REPO/actions/artifacts/$ARTIFACT_ID/zip" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -o build-log.zip

if [ -f build-log.zip ]; then
    echo "✅ Build log downloaded: build-log.zip"
    unzip -o build-log.zip
    if [ -f build.log ]; then
        echo ""
        echo "Checking build result..."
        if grep -q "BUILD SUCCEEDED" build.log; then
            echo "✅ BUILD SUCCEEDED!"
        else
            echo "❌ BUILD FAILED!"
            echo ""
            echo "Error summary:"
            grep -i "error:" build.log | head -20 || echo "No errors found in log"
        fi
    fi
else
    echo "❌ Failed to download artifact"
    exit 1
fi
