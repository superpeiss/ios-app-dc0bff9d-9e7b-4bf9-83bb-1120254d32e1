#!/bin/bash
# Script to query GitHub Actions workflow runs

set -e

GITHUB_TOKEN="$1"
OWNER="$2"
REPO="$3"

if [ -z "$GITHUB_TOKEN" ] || [ -z "$OWNER" ] || [ -z "$REPO" ]; then
    echo "Usage: $0 <github_token> <owner> <repo>"
    exit 1
fi

echo "Fetching workflow runs for $OWNER/$REPO..."
echo ""

RESPONSE=$(curl -k -s -X GET \
  "https://api.github.com/repos/$OWNER/$REPO/actions/runs?per_page=5" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28")

# Parse and display workflow runs
echo "$RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)

if 'workflow_runs' not in data or len(data['workflow_runs']) == 0:
    print('No workflow runs found.')
    sys.exit(0)

print(f'Latest Workflow Runs:')
print('=' * 80)

for run in data['workflow_runs'][:5]:
    status = run.get('status', 'unknown')
    conclusion = run.get('conclusion', 'N/A')
    name = run.get('name', 'Unknown')
    run_number = run.get('run_number', 'N/A')
    created_at = run.get('created_at', 'N/A')
    html_url = run.get('html_url', 'N/A')

    status_emoji = '⏳' if status == 'in_progress' else '✅' if conclusion == 'success' else '❌' if conclusion == 'failure' else '⚪'

    print(f'{status_emoji} Run #{run_number} - {name}')
    print(f'   Status: {status}')
    print(f'   Conclusion: {conclusion}')
    print(f'   Created: {created_at}')
    print(f'   URL: {html_url}')
    print()
"

# Get the latest run ID
LATEST_RUN_ID=$(echo "$RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if 'workflow_runs' in data and len(data['workflow_runs']) > 0:
    print(data['workflow_runs'][0]['id'])
" 2>/dev/null)

if [ -n "$LATEST_RUN_ID" ]; then
    echo "To download build log:"
    echo "./scripts/download_build_log.sh $GITHUB_TOKEN $OWNER $REPO $LATEST_RUN_ID"
fi
