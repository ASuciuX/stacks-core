#!/bin/bash

# for specific packages creates the outpup
# removes everything except .txt files

# moves to mutation-testing folder
cd ../packages-output

### Run mutation testing on the packages uncommented
### develop commit run: 1f5cc3f8691c0c1ed98b1931a9fa7f712b8cac0d

# # Run mutation testing for stx-genesis package
# cargo mutants --package stx-genesis --output stx-genesis -j 4 || true
# mv stx-genesis/mutants.out/*.txt stx-genesis/ || true
# rm -rf stx-genesis/mutants.out || true

# # Run mutation testing for pox-locking package
# cargo mutants --package pox-locking --output pox-locking -j 4 || true
# mv pox-locking/mutants.out/*.txt pox-locking/ || true
# rm -rf pox-locking/mutants.out || true

# # Run mutation testing for libsigner package
# cargo mutants --package libsigner --output libsigner -j 4 || true
# mv libsigner/mutants.out/*.txt libsigner/ || true
# rm -rf libsigner/mutants.out || true

# # Run mutation testing for libstackerdb package
# cargo mutants --package libstackerdb --output libstackerdb -j 4 || true
# mv libstackerdb/mutants.out/*.txt libstackerdb/ || true
# rm -rf libstackerdb/mutants.out || true

# # # Run mutation testing for stacks-common package
# cargo mutants --package stacks-common --output stacks-common -j 4 || true
# mv stacks-common/mutants.out/*.txt stacks-common/ || true
# rm -rf stacks-common/mutants.out || true

# # Run mutation testing for clarity package
# cargo mutants --package clarity --output clarity -j 4 || true
# mv clarity/mutants.out/*.txt clarity/ || true
# rm -rf clarity/mutants.out || true

# # Run mutation testing for stacks-signer package - working, 10 min approx. 
# cargo mutants --package stacks-signer --output stacks-signer -j 4 || true
# mv stacks-signer/mutants.out/*.txt stacks-signer/ || true
# rm -rf stacks-signer/mutants.out || true

### fails basic build & test
# Commented out mutation testing for stacks-node package due to test errors and long compile/testing time
cargo mutants --package stacks-node --output stacks-node -j 4 || true
mv stacks-node/mutants.out/*.txt stacks-node/ || true
rm -rf stacks-node/mutants.out || true

### fails basic build & test
# Commented out mutation testing for stackslib package due to long compile/testing time
cargo mutants --package stackslib --output stackslib -j 4 || true
mv stackslib/mutants.out/*.txt stackslib/ || true
rm -rf stackslib/mutants.out || true