#!/bin/bash

# for specific packages creates the outpup
# removes everything except .txt files

# moves to mutation-testing folder
cd ../packages-output

### Run mutation testing on the packages uncommented
### next commit run 6bdc9d5f8f872afd91a56089d7cceb7dcb7ddf9b


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

# # Run mutation testing for pox-locking package
cargo mutants --package pox-locking --output pox-locking -j 4 || true
mv pox-locking/mutants.out/*.txt pox-locking/ || true
rm -rf pox-locking/mutants.out || true
echo "finished with pox-locking"

# # Run mutation testing for relay-server package
cargo mutants --package relay-server --output relay-server -j 4 || true
mv relay-server/mutants.out/*.txt relay-server/ || true
rm -rf relay-server/mutants.out || true
echo "finished with relay-server"

# # Run mutation testing for stx-genesis package
cargo mutants --package stacks-common --output stacks-common -j 4 || true
mv stacks-common/mutants.out/*.txt stacks-common/ || true
rm -rf stacks-common/mutants.out || true
echo "finished with stacks-common"

# Run mutation testing for libsigner package
cargo mutants --package libsigner --output libsigner -j 4 || true
mv libsigner/mutants.out/*.txt libsigner/ || true
rm -rf libsigner/mutants.out || true
echo "finished with libsigner"

# Run mutation testing for libstackerdb package
cargo mutants --package libstackerdb --output libstackerdb -j 4 || true
mv libstackerdb/mutants.out/*.txt libstackerdb/ || true
rm -rf libstackerdb/mutants.out || true
echo "finished with libstackerdb"

# Run mutation testing for stacks-signer package - working, 10 min approx. 
cargo mutants --package stacks-signer --output stacks-signer -j 4 || true
mv stacks-signer/mutants.out/*.txt stacks-signer/ || true
rm -rf stacks-signer/mutants.out || true
echo "finished with stacks-signer"

### fails basic build & test
# Commented out mutation testing for stackslib package due to long compile/testing time
cargo mutants --package stackslib --output stackslib -j 4 || true
mv stackslib/mutants.out/*.txt stackslib/ || true
rm -rf stackslib/mutants.out || true
echo "finished with stackslib"

### fails basic build & test
# Commented out mutation testing for stacks-node package due to test errors and long compile/testing time
cargo mutants --package stacks-node --output stacks-node -j 4 || true
mv stacks-node/mutants.out/*.txt stacks-node/ || true
rm -rf stacks-node/mutants.out || true
echo "finished with stacks-node"



