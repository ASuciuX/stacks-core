# script that makes .git for the differences
# it saves the .git on scripts folder

# run from scripts folder
cd ..
git diff > git.diff

# it runs cargo mutants for those specific changed functions and outputs to /temp/mutants.out
# for faster builds: increase number to 4 if at least 16 gb ram and 6 cores CPU
cargo mutants --no-shuffle -j 2 -vV --in-diff git.diff --output temp/

# go to scripts folder level
cd scripts

# call append-match-package.sh to update the content from the stable output
sh append-match-package.sh

# removes extra files
rm -rf ../git.diff
rm -rf ../temp
