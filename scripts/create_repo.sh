#!/bin/bash
# Script to create GitHub repository using fine-grained token

set -e

GITHUB_TOKEN="$1"
REPO_NAME="$2"
REPO_DESCRIPTION="${3:-iOS Cloud File Browser App}"

if [ -z "$GITHUB_TOKEN" ] || [ -z "$REPO_NAME" ]; then
    echo "Usage: $0 <github_token> <repo_name> [description]"
    exit 1
fi

echo "Creating GitHub repository: $REPO_NAME"

RESPONSE=$(curl -k -s -X POST https://api.github.com/user/repos \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -d "{\"name\":\"$REPO_NAME\",\"description\":\"$REPO_DESCRIPTION\",\"public\":true,\"auto_init\":false}")

REPO_URL=$(echo "$RESPONSE" | grep -o '"html_url": *"[^"]*"' | head -1 | sed 's/"html_url": *"\(.*\)"/\1/')
SSH_URL=$(echo "$RESPONSE" | grep -o '"ssh_url": *"[^"]*"' | head -1 | sed 's/"ssh_url": *"\(.*\)"/\1/')

if [ -n "$REPO_URL" ]; then
    echo "✅ Repository created successfully!"
    echo "URL: $REPO_URL"
    echo "SSH: $SSH_URL"
else
    echo "❌ Failed to create repository"
    echo "$RESPONSE"
    exit 1
fi
