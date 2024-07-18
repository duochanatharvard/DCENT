#!/bin/bash

# Path to the directory list file
dir_list_file="dir_list.txt"

# Read each line in the file
while IFS= read -r dir_path; do
    # Check if the directory exists; if not, create it
    if [ ! -d "$dir_path" ]; then
        mkdir -p "$dir_path"
        echo "Created directory: $dir_path"
    else
        echo "Directory already exists: $dir_path"
    fi
done < "$dir_list_file"

echo "All directories are set up."

