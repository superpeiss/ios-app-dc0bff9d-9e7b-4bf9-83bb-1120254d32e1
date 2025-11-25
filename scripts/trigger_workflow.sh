#!/bin/bash
# Script to trigger GitHub Actions workflow manually

set -e

GITHUB_TOKEN="$1"
OWNER="$2"
REPO="$3"
WORKFLOW_FILE="${4:-ios-build.yml}"

if [ -z "$GITHUB_TOKEN" ] || [ -z "$OWNER" ] || [ -z "$REPO" ]; then
    echo "Usage: $0 <github_token> <owner> <repo> [workflow_file]"
    echo "Example: $0 ghp_xxx superpeiss my-repo ios-build.yml"
    exit 1
fi

echo "Triggering workflow: $WORKFLOW_FILE"
echo "Repository: $OWNER/$REPO"

RESPONSE=$(curl -k -s -X POST \
  "https://api.github.com/repos/$OWNER/$REPO/actions/workflows/$WORKFLOW_FILE/dispatches" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -d '{"ref":"main"}')

if [ -z "$RESPONSE" ]; then
    echo "✅ Workflow triggered successfully!"
    echo "Check status at: https://github.com/$OWNER/$REPO/actions"
else
    echo "Response: $RESPONSE"
fi

echo ""
echo "Waiting 5 seconds for workflow to start..."
sleep 5

# Get the latest run
echo "Fetching workflow run status..."
./scripts/query_workflow.sh "$GITHUB_TOKEN" "$OWNER" "$REPO"
