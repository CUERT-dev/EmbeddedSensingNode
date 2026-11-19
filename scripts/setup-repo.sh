#!/usr/bin/env bash
set -euo pipefail

REPO="${1:?usage: setup-repo.sh <owner/repo>}"

git branch -M main
git push -u origin main
git checkout -B develop
git push -u origin develop

for BRANCH in main develop; do
  gh api -X PUT "repos/$REPO/branches/$BRANCH/protection" --input - <<JSON
{
  "required_status_checks": { "strict": true, "contexts": ["format", "build"] },
  "enforce_admins": true,
  "required_pull_request_reviews": { "required_approving_review_count": 1, "dismiss_stale_reviews": true },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
JSON
done

gh api -X PATCH "repos/$REPO" -f default_branch=develop -F delete_branch_on_merge=true -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false
