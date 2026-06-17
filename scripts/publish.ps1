<#
.SYNOPSIS
    Publishes blog posts from Obsidian vault to the blog repository.

.DESCRIPTION
    Copies markdown files from your Obsidian vault to the blog's content directory,
    commits the changes, and pushes to the remote repository.

.PARAMETER VaultPath
    Path to the Obsidian blog posts folder. Defaults to $env:OBSIDIAN_VAULT_PATH
    or the configured default path.

.PARAMETER DryRun
    If specified, shows what would be copied without making changes.

.EXAMPLE
    .\publish.ps1
    Publishes posts using the default or environment-configured vault path.

.EXAMPLE
    .\publish.ps1 -VaultPath "D:\MyVault\blog-posts"
    Publishes posts from a specific vault path.

.EXAMPLE
    .\publish.ps1 -DryRun
    Shows what would be published without making changes.
#>

param(
    [Parameter()]
    [string]$VaultPath,
    
    [Parameter()]
    [switch]$DryRun
)

# ============================================================
# CONFIGURATION - Edit this section to customize
# ============================================================
$DefaultVaultPath = "C:\Vault\blog-posts"
# ============================================================

# Determine the vault path to use
$SourcePath = if ($VaultPath)
{
    $VaultPath
} elseif ($env:OBSIDIAN_VAULT_PATH)
{
    $env:OBSIDIAN_VAULT_PATH
} else
{
    $DefaultVaultPath
}

# Get the script's directory (blog repo root)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$DestPath = Join-Path $RepoRoot "src\content\posts"

# Colors for output
function Write-Success
{ param($Message) Write-Host $Message -ForegroundColor Green 
}
function Write-Info
{ param($Message) Write-Host $Message -ForegroundColor Cyan 
}
function Write-Warning
{ param($Message) Write-Host $Message -ForegroundColor Yellow 
}
function Write-Error
{ param($Message) Write-Host $Message -ForegroundColor Red 
}

# Header
Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  Blog Publisher - Breaking Changes" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

# Validate source path
if (-not (Test-Path $SourcePath))
{
    Write-Error "Error: Vault path not found: $SourcePath"
    Write-Host ""
    Write-Host "Please either:"
    Write-Host "  1. Edit the `$DefaultVaultPath in this script"
    Write-Host "  2. Set the OBSIDIAN_VAULT_PATH environment variable"
    Write-Host "  3. Pass the path as a parameter: .\publish.ps1 -VaultPath 'C:\path\to\vault'"
    exit 1
}

Write-Info "Source: $SourcePath"
Write-Info "Destination: $DestPath"
Write-Host ""

# Get markdown files from vault
$VaultFiles = Get-ChildItem -Path $SourcePath -Filter "*.md" -File

if ($VaultFiles.Count -eq 0)
{
    Write-Warning "No markdown files found in vault."
    exit 0
}

Write-Info "Found $($VaultFiles.Count) markdown file(s) in vault"
Write-Host ""

# Track changes
$Copied = @()
$Unchanged = @()

foreach ($File in $VaultFiles)
{
    $DestFile = Join-Path $DestPath $File.Name
    
    $ShouldCopy = $false
    $Reason = ""
    
    if (-not (Test-Path $DestFile))
    {
        $ShouldCopy = $true
        $Reason = "new"
    } else
    {
        $SourceHash = (Get-FileHash $File.FullName -Algorithm MD5).Hash
        $DestHash = (Get-FileHash $DestFile -Algorithm MD5).Hash
        
        if ($SourceHash -ne $DestHash)
        {
            $ShouldCopy = $true
            $Reason = "modified"
        }
    }
    
    if ($ShouldCopy)
    {
        if ($DryRun)
        {
            Write-Host "  [DRY RUN] Would copy ($Reason): $($File.Name)" -ForegroundColor Yellow
        } else
        {
            Copy-Item -Path $File.FullName -Destination $DestFile -Force
            Write-Success "  Copied ($Reason): $($File.Name)"
        }
        $Copied += $File.Name
    } else
    {
        $Unchanged += $File.Name
    }
}

Write-Host ""

if ($Copied.Count -eq 0)
{
    Write-Info "No changes to publish."
    exit 0
}

Write-Success "$($Copied.Count) file(s) copied, $($Unchanged.Count) unchanged"
Write-Host ""

if ($DryRun)
{
    Write-Warning "Dry run complete. No changes were made."
    exit 0
}

# Git operations
Write-Info "Committing and pushing changes..."
Write-Host ""

Set-Location $RepoRoot

# Stage changes
git add "src/content/posts/*.md"

# Create commit message
$CommitFiles = $Copied -join ", "
if ($CommitFiles.Length -gt 50)
{
    $CommitMessage = "Publish: $($Copied.Count) post(s) updated"
} else
{
    $CommitMessage = "Publish: $CommitFiles"
}

# Commit
$CommitResult = git commit -m $CommitMessage 2>&1

if ($LASTEXITCODE -ne 0)
{
    if ($CommitResult -match "nothing to commit")
    {
        Write-Info "Nothing to commit (files may already be staged)"
    } else
    {
        Write-Error "Commit failed: $CommitResult"
        exit 1
    }
} else
{
    Write-Success "Committed: $CommitMessage"
}

# Push
Write-Info "Pushing to remote..."
$PushResult = git push 2>&1

if ($LASTEXITCODE -ne 0)
{
    Write-Error "Push failed: $PushResult"
    exit 1
}

Write-Host ""
Write-Success "========================================" 
Write-Success "  Published successfully!" 
Write-Success "========================================" 
Write-Host ""
Write-Info "CI will now build and deploy your changes."
Write-Host ""
