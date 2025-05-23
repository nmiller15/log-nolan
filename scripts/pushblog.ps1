# Define source and destination paths
$MARKDOWN_DIR = "C:\Vault\blog-posts"
$ATTACHMENTS_DIR = "C:\Vault\utils\attachments"
$S3_BUCKET_NAME = "nolanmiller-image-hosting"
$SCRIPTS = Resolve-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition)
$HUGO_SITE_DIR = Resolve-Path (Join-Path $SCRIPTS "..")
$CONTENT = Join-Path $HUGO_SITE_DIR "content\posts"
$CURRENT_PATH = Get-Location

function log {
    param($message)
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $message"
}

log "Executing blog pipeline script"

log "Replacing attached images with s3 links"
python3 $SCRIPTS/images.py $MARKDOWN_DIR $S3_BUCKET_NAME $ATTACHMENTS_DIR

log "Moving files from $MARKDOWN_DIR to $CONTENT"
robocopy $MARKDOWN_DIR $CONTENT /MIR

Set-Location -Path $HUGO_SITE_DIR

log "Running Hugo build..."
hugo

log "Committing changes to GitHub repository"
git add -A
$commit_message = "You Got Mail... on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git commit -m $commit_message -m "Automated commit brought to you by \~POWERSHELL\~"

git pull --rebase -X ours
git push

log "Pushing changes to DEV.to"
Set-Location -Path $SCRIPTS
python3 pushtodev.py $MARKDOWN_DIR

log "Blog pipeline exited successfully"
Set-Location -Path $CURRENT_PATH
