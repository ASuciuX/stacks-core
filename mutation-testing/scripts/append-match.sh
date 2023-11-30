#!/bin/bash

PR_FOLDER="./../trials/mutants.out.old"
STABLE_FOLDER="./../trials/mutants-stable"
FILES=("caught.txt" "missed.txt" "timeout.txt" "unviable.txt")

echo "Starting script..."
echo "PR Folder: $PR_FOLDER"
echo "STABLE Folder: $STABLE_FOLDER"
echo "Files to process: ${FILES[*]}"

# Function to escape special characters for awk
escape_for_awk() {
    echo "$1" | sed -E 's/([][\/$*.^|])/\\&/g'
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

            # Extract the core pattern without the line number and escape it for awk
            core_pattern=$(echo "$line" | sed -E 's/^[^:]+:[0-9]+:(.+)/\1/')
            escaped_pattern=$(escape_for_awk "$core_pattern")
            echo "Extracted and escaped pattern: $escaped_pattern"

            # Iterate over each file in the STABLE folder
            for target_file in "${FILES[@]}"; do
                target_path="$STABLE_FOLDER/$target_file"
                echo "Checking against STABLE file: $target_path"

                # Remove the line matching the pattern, ignoring line numbers
                awk -v pat="$escaped_pattern" '$0 !~ pat' "$target_path" > temp_file && mv temp_file "$target_path"
            done
        done < "$pr_file"
    else
        echo "PR file $pr_file is empty or does not exist, skipping..."
    fi
done

# After processing all lines, append contents from PR_DIR to STABLE_DIR
for file in "${FILES[@]}"; do
    cat "$PR_FOLDER/$file" >> "$STABLE_FOLDER/$file"
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
