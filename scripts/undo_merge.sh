#!/bin/bash

# 0) Check for unstaged changes but ignore untracked files and submodules
if ! git diff --exit-code --ignore-submodules; then
    echo "You have unstaged changes. Please commit or stash them."
    exit 1
fi

# Check if the most recent commit is a merge commit
if ! git log -n 1 --pretty=%P | grep ' '; then
    echo "The most recent commit is not a merge commit. Exiting."
    exit 1
fi

# Automatically get the merge commit and parent commit
MERGE_COMMIT=$(git rev-parse HEAD)
PARENT_COMMIT=$(git log -n 1 --pretty=%P | awk '{print $1}')

echo "Merge commit: $MERGE_COMMIT"
echo "Parent commit: $PARENT_COMMIT"

# 1) Reset the branch to remove the merge commit
git reset --soft "$PARENT_COMMIT"

# 2) Reset hard to delete the tracked changes
git reset --hard

# 3) Remove the now untracked new files
git diff --diff-filter=A --name-only "$PARENT_COMMIT" "$MERGE_COMMIT" | while read -r file; do
    # Check if the file still exists (hasn't been deleted by another action)
    if [ -e "$file" ]; then
        # Remove the file
	echo "Removing newly untracked file: $file"
        rm -v "$file"
    fi
done

