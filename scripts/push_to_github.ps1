# Define source and destination paths
$sourcePath = "C:\Users\NMiller\OneDrive - CAB\Documents\Vault\blog-posts"
$destinationPath = "C:\Users\NMiller\OneDrive - CAB\Documents\blog-nolan\content\posts"

# Move the files from source to destination
Write-Host "Moving files from $sourcePath to $destinationPath"
robocopy $sourcePath $destinationPath /E /Z /MIR

# Change to the GitHub repository directory
Set-Location -Path "C:\Users\NMiller\OneDrive - CAB\Documents\blog-nolan"

# Execute Hugo build
Write-Host "Running Hugo build..."
hugo

# Add all files to Git
git add -A

# Commit changes with a message including the current date
$commitMessage = "Automated commit on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git commit -m $commitMessage

# Push changes to GitHub
Write-Host "Pushing changes to GitHub..."
git push