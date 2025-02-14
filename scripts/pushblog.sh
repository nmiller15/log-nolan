#!/bin/bash

# Define source and destination paths
MARKDOWN_DIR="/Users/nolanmiller/Google Drive/My Drive/Vault/blog-posts"
HUGO_SITE_DIR="/Users/nolanmiller/Projects/log-nolan"
SCRIPTS="$HUGO_SITE_DIR/scripts"
CONTENT="$HUGO_SITE_DIR/content/posts"
CURRENT_PATH="$(pwd)"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

run_safe() {
    "$@"
    if [ $? -ne 0 ]; then
        log "Error executing: $1"
        exit 1
    fi
}

log "Executing blog pipeline script"

log "Committing source file changes from $MARKDOWN_DIR"
cd "$MARKDOWN_DIR" || exit

run_safe git add -A
commit_message="Automated commit on $(date '+%Y-%m-%d %H:%M:%S')"
run_safe git commit -m "$commit_message"

run_safe git pull --rebase -X ours
run_safe git push 

# Move the files from source to destination
log "Moving files from $MARKDOWN_DIR to $CONTENT"
run_safe rsync -av --delete "$MARKDOWN_DIR/" "$CONTENT/"

# Change to the GitHub repository directory
cd "$HUGO_SITE_DIR" || exit

log "Running Hugo build..."
run_safe hugo

log "Committing changes to GitHub repository"
run_safe git add -A
commit_message="Automated commit on $(date '+%Y-%m-%d %H:%M:%S')"
run_safe git commit -m "$commit_message"

run_safe git pull --rebase -X ours
run_safe git push 

# Change to the scripts directory
log "Pushing changes to DEV.to"
cd "$SCRIPTS" || exit
python3 pushtodev.py "$CONTENT"

# Return to the original directory
log "Blog pipeline exited successfully"
cd "$CURRENT_PATH" || exit