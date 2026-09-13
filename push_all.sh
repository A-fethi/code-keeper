#!/bin/bash
set -e

MSG="${1:-update changes}"
GITLAB_HOST="192.168.56.20"
# Uses your environment token or falls back to the default Ansible token
GITLAB_TOKEN="${GITLAB_TOKEN:-glpat-codekeepersecrettoken123}"

echo "==> 1. Pushing monorepo to GitHub..."
git add .
git commit -m "$MSG" || echo "No new changes to commit in root."
git push origin main

echo "==> 2. Syncing subtrees directly to GitLab..."

sync_gitlab_app() {
  APP=$1
  echo "==> Syncing $APP to http://$GITLAB_HOST/code-keeper/$APP.git..."
  
  # Clean up old temp branch if present
  git branch -D "temp-$APP" 2>/dev/null || true

  # Split apps/<service> and push directly to GitLab repo
  if git subtree split --prefix="apps/$APP" -b "temp-$APP"; then
    git push "http://root:${GITLAB_TOKEN}@${GITLAB_HOST}/code-keeper/${APP}.git" "temp-$APP:main" --force
    git branch -D "temp-$APP"
  else
    echo "ERROR: Subtree split failed for apps/$APP"
  fi
}

sync_gitlab_app "terraform"
sync_gitlab_app "api-gateway"
sync_gitlab_app "inventory"
sync_gitlab_app "billing"

echo "==> All pushed successfully to both GitHub and GitLab!"