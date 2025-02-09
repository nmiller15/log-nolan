#!/bin/bash

# Define directories
MARKDOWN_DIR="/Users/nolanmiller/Google Drive/My Drive/Vault/blog-posts"
HUGO_SITE_DIR="/Users/nolanmiller/Projects/log-nolan"
REMOTE="origin"
BRANCH="main"
CURRENT_DIR="$(pwd)"

# Function to log messages with timestamp
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to safely execute commands with error checking
run_safe() {
    "$@"
    if [ $? -ne 0 ]; then
        log "Error executing: $1"
        exit 1
    fi
}

# 1. Stash any local changes, pull remote, restore stash, commit and push changes to GitHub
log "Stashing local changes in markdown directory"
cd "$MARKDOWN_DIR" || exit 1
run_safe git add -A
run_safe git stash save "auto-backup-before-sync"
log "Pulling changes from remote"
run_safe git pull "$REMOTE" "$BRANCH"
log "Restoring stashed changes"
run_safe git stash pop || log "No stash to pop or merge conflict occurred"
log "Committing changes"
run_safe git commit -am "Sync markdown files"
log "Pushing changes to GitHub"
run_safe git push "$REMOTE" "$BRANCH"

# 2. Pull remote changes for Hugo site
log "Pulling changes from remote in Hugo site directory"
cd "$HUGO_SITE_DIR" || exit 1
run_safe git pull "$REMOTE" "$BRANCH"

# 3. Copy markdown directory content to Hugo site content directory
<<<<<<< HEAD
=======
log "Backing up Hugo site's existing content"
run_safe cp -r "$HUGO_SITE_DIR/content/posts" "$HUGO_SITE_DIR/content/posts-backup-$(date '+%Y%m%d%H%M%S')"
>>>>>>> 99380ceb7c14add502d0ca6383edfd692bfa05b1
log "Copying markdown posts to Hugo content directory"
run_safe cp -r "$MARKDOWN_DIR"/* "$HUGO_SITE_DIR/content/posts/"
log "Verifying that no uncommitted changes exist in Hugo site"
run_safe git diff --quiet || (log "Uncommitted changes detected in Hugo site"; exit 1)

# 4. Build the site using Hugo
log "Building Hugo site"
run_safe hugo

# 5. Commit and push changes to GitHub
log "Committing Hugo site changes"
cd "$HUGO_SITE_DIR" || exit 1
run_safe git add -A
run_safe git commit -m "Build Hugo site"
log "Pushing Hugo site changes to GitHub"
run_safe git push "$REMOTE" "$BRANCH"

# 6. Call the Python script for dev.to upload/edit
log "Running Python script to upload/edit posts on dev.to"
cd "$HUGO_SITE_DIR/scripts" || exit 1
python3 /path/to/upload_to_devto.py "$MARKDOWN_DIR"

cd "$CURRENT_DIR" || exit 1
log "Pipeline executed successfully"
