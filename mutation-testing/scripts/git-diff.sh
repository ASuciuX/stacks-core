# script that makes .git for the differences
# it saves the .git on scripts folder

# it runs cargo mutants for those specific changed functions

# it creates a new output


# then the append-match-package.sh is called
## TODO: update append-match-package.sh with what would be the output from the cargo mutants diff


# the append-match-package.sh
## goes through each line in the output and based on the package ( first element before /)
### verifies the line with the other lines in that specific folder
#### in our case folder_name == package_name

