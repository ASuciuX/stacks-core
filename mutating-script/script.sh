#!/bin/bash

### Delete irelevant files


PR_DIR="./../mutants.out"

# Change to the PR_DIR
cd "$PR_DIR"

# Delete all files except .txt files
find . -type f ! -name "*.txt" -delete

# Delete all empty directories (log dir)
find . -type d -empty -delete


### Append from PR_DIR to STABLE_DIR

# # Directories
# STABLE_DIR="./../mutants.out.old"

# # Array of file names
# FILES=("caught.txt" "missed.txt" "timeout.txt" "unviable.txt")

# # Function to remove a line from a file
# remove_line() {
#     local line="$1"
#     local file="$2"
#     # Use grep to filter out the line and save it back to the file
#     grep -Fv "$line" "$file" > temp.txt && mv temp.txt "$file"
# }

# # Process each file
# for file in "${FILES[@]}"; do
#     while IFS= read -r line; do
#         # Check and remove the line from any file in STABLE_DIR if it exists
#         for check_file in "${FILES[@]}"; do
#             if grep -Fxq "$line" "$STABLE_DIR/$check_file"; then
#                 remove_line "$line" "$STABLE_DIR/$check_file"
#             fi
#         done
#     done < "$PR_DIR/$file"
# done

# # After processing all lines, append contents from PR_DIR to STABLE_DIR
# for file in "${FILES[@]}"; do
#     cat "$PR_DIR/$file" >> "$STABLE_DIR/$file"
# done



