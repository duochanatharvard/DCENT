#!/bin/bash

# Change the directory to where your Member folders are.
# For example, if they are in a folder named 'members' in your home directory,
# you would write: cd ~/members
cd /home/dc1e23/chanlab/DCENT/DCLAT/GHCN
export subfolder_name="Round2"

# Find all directories with the pattern 'Member_*' and create a 'Round2' subdirectory in each.
for folder in Member_*; do
    if [ -d "$folder" ]; then # Check if it is a directory
        mkdir -p "$folder/$subfolder_name" # Create the Round2 folder
        echo "Created $subfolder_name in $folder"
    fi
done

# End of script
