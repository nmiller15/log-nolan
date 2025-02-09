#!/bin/bash
echo "Pushing blog posts to the website as user $(whoami)"

# Define source and destination paths
blog_posts_path="/Users/nolanmiller/Library/CloudStorage/GoogleDrive-nolan.miller77@gmail.com/My Drive/Vault/blog-posts"
content_posts_path="/Users/nolanmiller/Projects/log-nolan/content/posts"
repository_path="/Users/nolanmiller/Projects/log-nolan"
scripts_directory="$repository_path/scripts"
current_path="$(pwd)"

# Commit current changes to source control
echo "Committing changes to source control..."
cd "$blog_posts_path" || exit
echo $(pwd)

git add -A
commit_message="Automated commit on $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$commit_message"

git pull --rebase --strategy-option=ours
git push --force-with-lease

# Move the files from source to destination
echo "Moving files from $blog_posts_path to $content_posts_path"
rsync -av --delete "$blog_posts_path/" "$content_posts_path/"

# Change to the GitHub repository directory
cd "$repository_path" || exit

# Execute Hugo build
echo "Running Hugo build..."
hugo

git add -A
commit_message="Automated commit on $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$commit_message"

git pull --rebase --strategy-option=ours

# Change to the scripts directory
cd "$scripts_directory" || exit
python3 pushtodev.py "$blog_posts_path"

# Change back to the repository directory
cd "$repository_path" || exit

# Push changes to GitHub
echo "Pushing changes to GitHub..."
git push --force-with-lease

# Return to the original directory
cd "$current_path" || exit