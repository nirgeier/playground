#!/bin/bash

# This script is used to start the demo server.

# Step 01: Print random number to file
echo $RANDOM > random.txt

# Step 02: Add files
git add . || \
    echo "Failed to add file. Please check your changes."

# Step 03: Commit changes
git commit -m "Merge request Demo" || \
    echo "Failed to create commit. Please check your files."

# Step 04: Push changes to GitHub
git push 