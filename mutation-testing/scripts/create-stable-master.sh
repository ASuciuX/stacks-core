#!/bin/bash

# for specific packages creates the outpup
# removes everything except .txt files

# moves to mutation-testing folder
cd ../packages-output

### Run mutation testing on the packages uncommented
### master commit run 6bdc9d5f8f872afd91a56089d7cceb7dcb7ddf9b


# # Run mutation testing for clarity package
cargo mutants --package clarity --output clarity -j 4 || true
mv clarity/mutants.out/*.txt clarity/ || true
rm -rf clarity/mutants.out || true
echo "finished with clarity"

# # Run mutation testing for stx-genesis package
cargo mutants --package stx-genesis --output stx-genesis -j 4 || true
mv stx-genesis/mutants.out/*.txt stx-genesis/ || true
rm -rf stx-genesis/mutants.out || true
echo "finished with stx-genesis"

# # Run mutation testing for stx-genesis package
cargo mutants --package stacks-common --output stacks-common -j 4 || true
mv stacks-common/mutants.out/*.txt stacks-common/ || true
rm -rf stacks-common/mutants.out || true
echo "finished with stacks-common"

### fails basic build & test
# Commented out mutation testing for stacks-node package due to test errors and long compile/testing time
cargo mutants --package stacks-node --output stacks-node -j 4 || true
mv stacks-node/mutants.out/*.txt stacks-node/ || true
rm -rf stacks-node/mutants.out || true
echo "finished with stacks-node"

### fails basic build & test
# # Run mutation testing for blockstack-core package
cargo mutants --output blockstack-core -j 4 || true
mv blockstack-core/mutants.out/*.txt blockstack-core/ || true
rm -rf blockstack-core/mutants.out || true
echo "finished with blockstack-core"


