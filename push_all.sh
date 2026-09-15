#!/bin/bash
set -e

MSG="${1:-update changes}"
GITLAB_HOST="192.168.56.20"
# Set GITLAB_SSH_PORT to 22 (or 2222 if mapped to a custom host port)
GITLAB_SSH_PORT="${GITLAB_SSH_PORT:-22}"

echo "==> 1. Pushing monorepo to GitHub..."
git add .
git commit -m "$MSG" || echo "No new changes to commit in root."
git push iichi

echo "==> 2. Syncing microservices to GitLab via SSH..."

sync_gitlab_app() {
  APP=$1
  
  if [ "$GITLAB_SSH_PORT" -eq 22 ]; then
    SSH_URL="git@${GITLAB_HOST}:code-keeper/${APP}.git"
  else
    SSH_URL="ssh://git@${GITLAB_HOST}:${GITLAB_SSH_PORT}/code-keeper/${APP}.git"
  fi

  echo "==> Syncing $APP to $SSH_URL..."
  
  # Clean up old temporary branch if present
  git branch -D "temp-$APP" 2>/dev/null || true

  # Split apps/<service> and push directly via SSH
  if git subtree split --prefix="apps/$APP" -b "temp-$APP"; then
    git push "$SSH_URL" "temp-$APP:main" --force
    git branch -D "temp-$APP"
  else
    echo "ERROR: Subtree split failed for apps/$APP"
  fi
}

sync_gitlab_app "terraform"
sync_gitlab_app "api-gateway"
sync_gitlab_app "inventory"
sync_gitlab_app "billing"

echo "==> All pushed successfully via SSH to GitLab!"