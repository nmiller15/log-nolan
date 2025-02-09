# Define source and destination paths
$MARKDOWN_DIR = "G:\My Drive\Vault\blog-posts"
$HUGO_SITE_DIR = "C:\Users\NMiller\OneDrive - CAB\Documents\blog-nolan\"
$SCRIPTS = "$HUGO_SITE_DIR\scripts"
$CONTENT = "$HUGO_SITE_DIR\content\posts"
$CURRENT_PATH = Get-Location

function log {
    param($message)
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $message"
}

function run_safe {
    param($command)
    & $command
    if ($LASTEXITCODE -ne 0) {
        log "Error executing: $command"
        exit 1
    }
}

log "Executing blog pipeline script"

log "Committing source file changes from $MARKDOWN_DIR"
Set-Location -Path $MARKDOWN_DIR

run_safe "git pull"

run_safe "git add -A"
$commit_message = "Automated commit on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
run_safe "git commit -m '$commit_message'"

run_safe "git push"

# Move the files from source to destination
log "Moving files from $MARKDOWN_DIR to $CONTENT"
run_safe "robocopy $MARKDOWN_DIR $CONTENT /MIR"

# Change to the GitHub repository directory
Set-Location -Path $HUGO_SITE_DIR

log "Pulling changes from GitHub repository"
run_safe "git pull"

log "Running Hugo build..."
run_safe "hugo"

log "Committing changes to GitHub repository"
run_safe "git add -A"
$commit_message = "Automated commit on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
run_safe "git commit -m '$commit_message'"
run_safe "git push"

# Change to the scripts directory
log "Pushing changes to DEV.to"
Set-Location -Path $SCRIPTS
run_safe "python3 pushtodev.py '$CONTENT'"

# Return to the original directory
log "Blog pipeline exited successfully"
Set-Location -Path $CURRENT_PATH
