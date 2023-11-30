#!/bin/bash

PR_FOLDER="./../trials/mutants.out.old"
STABLE_FOLDER="./../mutants-stable"
FILES=("caught.txt" "missed.txt" "timeout.txt" "unviable.txt")

echo "Starting script..."
echo "PR Folder: $PR_FOLDER"
echo "STABLE Folder: $STABLE_FOLDER"
echo "Files to process: ${FILES[*]}"

# Function to escape forward slashes
escape_slashes() {
    echo "$1" | sed 's_/_\\/_g'
}

# Iterate over the specified files
for file in "${FILES[@]}"; do
    pr_file="$PR_FOLDER/$file"
    stable_file="$STABLE_FOLDER/$file"

    echo "Processing file: $file"

    # Check if PR file exists and is not empty
    if [[ -s "$pr_file" ]]; then
        # Read each line from the PR file
        while IFS= read -r line; do
            echo "Reading line from PR file: $line"

            # Extract the pattern without the line number and escape slashes
            pattern=$(echo "$line" | sed -E 's/:[0-9]+:/::/' | escape_slashes)
            echo "Extracted pattern: $pattern"

            # Iterate over each file in the STABLE folder
            for target_file in "${FILES[@]}"; do
                target_path="$STABLE_FOLDER/$target_file"
                echo "Checking against STABLE file: $target_path"
                # Remove the matching line from the STABLE file, ignoring line numbers
                # Adding '' for macOS compatibility
                sed -i '' "/$pattern/d" "$target_path"
            done
        done < "$pr_file"
    else
        echo "PR file $pr_file is empty or does not exist, skipping..."
    fi
done

# Echo the contents of the STABLE folder for verification
echo "Updated contents of STABLE folder:"
for file in "${FILES[@]}"; do
    stable_file="$STABLE_FOLDER/$file"
    echo "Contents of $stable_file:"
    cat "$stable_file"
    echo ""
done

echo "Script completed."
