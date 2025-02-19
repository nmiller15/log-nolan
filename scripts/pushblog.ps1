# Define source and destination paths
$MARKDOWN_DIR = "G:\My Drive\Vault\blog-posts"
$ATTACHMENTS_DIR = "G:\My Drive\Vault\attachments"
$S3_BUCKET_NAME = "nolanmiller-image-hosting"
$HUGO_SITE_DIR = "C:\Users\NMiller\OneDrive - CAB\Documents\blog-nolan\"
$SCRIPTS = "$HUGO_SITE_DIR\scripts"
$CONTENT = "$HUGO_SITE_DIR\content\posts"
$CURRENT_PATH = Get-Location

function log {
    param($message)
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $message"
}

log "Executing blog pipeline script"

log "Replacing attached images with s3 links"
python3 $SCRIPTS/images.py $MARKDOWN_DIR $S3_BUCKET_NAME $ATTACHMENTS_DIR

log "Committing source file changes from $MARKDOWN_DIR"
Set-Location -Path $MARKDOWN_DIR

git add -A
$commit_message = "Automated commit on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git commit -m "$commit_message"

git pull --rebase -X ours
git push

# Move the files from source to destination
log "Moving files from $MARKDOWN_DIR to $CONTENT"
robocopy $MARKDOWN_DIR $CONTENT /MIR

# Change to the GitHub repository directory
Set-Location -Path $HUGO_SITE_DIR


log "Running Hugo build..."
hugo

log "Committing changes to GitHub repository"
git add -A
$commit_message = "Automated commit on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git commit -m '$commit_message'

git pull --rebase -X ours
git push

# Change to the scripts directory
log "Pushing changes to DEV.to"
Set-Location -Path $SCRIPTS
python3 pushtodev.py $CONTENT

# Return to the original directory
log "Blog pipeline exited successfully"
Set-Location -Path $CURRENT_PATH
