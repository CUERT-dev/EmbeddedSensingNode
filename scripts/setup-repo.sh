#!/usr/bin/env bash
set -euo pipefail

REPO="${1:?usage: setup-repo.sh <owner/repo>}"

protect() {
  gh api -X PUT "repos/$REPO/branches/$1/protection" --input - <<JSON
{
  "required_status_checks": $2,
  "enforce_admins": true,
  "required_pull_request_reviews": { "required_approving_review_count": $3, "dismiss_stale_reviews": true, "require_code_owner_reviews": $4 },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
JSON
}

CHECKS='{ "strict": true, "contexts": ["flow", "format", "build"] }'

protect main null 1 true
protect Developing "$CHECKS" 1 false
protect Testing "$CHECKS" 1 false
protect Validating "$CHECKS" 1 true

gh api -X PATCH "repos/$REPO" -F delete_branch_on_merge=false -F allow_squash_merge=true -F allow_merge_commit=true -F allow_rebase_merge=false
