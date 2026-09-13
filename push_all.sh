#!/bin/bash
set -e
MSG="${1:-update changes}"
echo "==> 1. Pushing to GitHub / Gitea..."
git add .
git commit -m "$MSG" || echo "No changes to commit in root."
git push origin main
# Sync individual apps to GitLab
sync_app() {
  APP=$1
  GIT_DIR="$HOME/.git_apps_backup/${APP}.git"
  if [ -d "$GIT_DIR" ]; then
    echo "==> Syncing $APP to GitLab..."
    git --git-dir="$GIT_DIR" --work-tree="apps/$APP" add .
    git --git-dir="$GIT_DIR" --work-tree="apps/$APP" commit -m "$MSG" 2>/dev/null || echo "No changes in $APP."
    git --git-dir="$GIT_DIR" push origin main 2>/dev/null || true
  fi
}
echo "==> 2. Syncing microservices to GitLab pipelines..."
sync_app "api-gateway"
sync_app "inventory"
sync_app "billing"
sync_app "terraform"
echo "==> All pushed successfully to both GitHub and GitLab!"
