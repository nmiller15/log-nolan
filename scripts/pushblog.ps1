# Define source and destination paths
$sourcePath = "G:\My Drive\Vault\blog-posts"
$destinationPath = "C:\Users\NMiller\OneDrive - CAB\Documents\blog-nolan\content\posts"
$currentPath = Get-Location

# Commit current changes to source control
Set-Location -Path $sourcePath

git add -A
$commitMessage = "Automated commit on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git commit -m $commitMessage

Write-Host "Pushing changes to GitHub..."
git pull --rebase --strategy-option=ours
git push

# Move the files from source to destination
Write-Host "Moving files from $sourcePath to $destinationPath"
robocopy $sourcePath $destinationPath /E /Z /MIR

# Change to the GitHub repository directory
Set-Location -Path "C:\Users\NMiller\OneDrive - CAB\Documents\blog-nolan"

# Execute Hugo build
Write-Host "Running Hugo build..."
hugo

git add -A
$commitMessage = "Automated commit on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git commit -m $commitMessage

Write-Host "Pushing changes to GitHub..."
git pull --rebase --strategy-option=ours
git push

Set-Location -Path "C:\Users\NMiller\OneDrive - CAB\Documents\blog-nolan\scripts"
python3 pushtodev.py "G:\My Drive\Vault\blog-posts"

Set-Location -Path $currentPath