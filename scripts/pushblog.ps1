# Define source and destination paths
$sourcePath = "G:\My Drive\Vault\blog-posts"
$destinationPath = "C:\Users\NMiller\OneDrive - CAB\Documents\blog-nolan\content\posts"
$currentPath = Get-Location

# Commit current changes to source control
Set-Location -Path $sourcePath

git pull --rebase --strategy-option=ours
git add -A

$commitMessage = "Automated commit on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

git commit -m $commitMessage
git push

# Move the files from source to destination
Write-Host "Moving files from $sourcePath to $destinationPath"
robocopy $sourcePath $destinationPath /E /Z /MIR

# Change to the GitHub repository directory
Set-Location -Path "C:\Users\NMiller\OneDrive - CAB\Documents\blog-nolan"

# Execute Hugo build
Write-Host "Running Hugo build..."
hugo

git pull --rebase --strategy-option=ours

# Add all files to Git
git add -A

# Commit changes with a message including the current date
$commitMessage = "Automated commit on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git commit -m $commitMessage

Set-Location -Path "C:\Users\NMiller\OneDrive - CAB\Documents\blog-nolan\scripts"
python3 pushtodev.py "G:\My Drive\Vault\blog-posts"

Set-Location -Path "C:\Users\NMiller\OneDrive - CAB\Documents\blog-nolan"

# Push changes to GitHub
Write-Host "Pushing changes to GitHub..."
git push

Set-Location -Path $currentPath