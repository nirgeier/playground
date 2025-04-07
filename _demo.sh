#!/bin/bash

# The name of the branch we wish to work on 
BR_NAME="demo-branch-$RANDOM"

# Step 01 - Create new branch
git checkout -b $BR_NAME

# Step 02: Print random number to file
echo $BR_NAME >> random.txt

# Step 03: Add files
git add . || \
    echo "Failed to add file. Please check your changes."

# Step 04: Commit changes
git commit -m "Merge request Demo" || \
    echo "Failed to create commit. Please check your files."

# Step 05: Push changes to GitHub
git push
