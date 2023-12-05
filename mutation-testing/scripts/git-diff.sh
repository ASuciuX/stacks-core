# script that makes .git for the differences
# it saves the .git on scripts folder

# add untracked files to git diff
# go to root folder
cd ./../..

# # run git status on root
# untracked_files=($(git ls-files --others --exclude-standard))

# # for each file untracked -> run git add file path
# echo "${untracked_files[@]}"
# for file in "${untracked_files[@]}"; do
#   git add -N "$file"
# done

# run from mutation-testing folder
cd mutation-testing


# get the differences since the last commit
last_commit_hash=$(<./packages-output/last_commit_hash.txt)
git diff "$last_commit_hash" > git.diff

# it runs cargo mutants for those specific changed functions and outputs to /temp/mutants.out
# for faster builds: increase number to 4 if at least 16 gb ram and 6 cores CPU
cargo mutants --no-shuffle -j 2 -vV --in-diff git.diff --output temp/

# go to scripts folder level
cd scripts

# call append-match-package.sh to update the content from the stable output
bash append-match-package.sh

# print the modified mutants for testing, to be deleted
echo "Files ending with .txt in ./temp/mutants.out:"
for file in ../temp/mutants.out/*.txt; do
    if [ -f "$file" ]; then
        echo "File: $file"
        echo "Contents:"
        cat "$file"
        echo "-------------------------"
    fi
done

# removes extra files
rm -rf ../git.diff
rm -rf ../temp
