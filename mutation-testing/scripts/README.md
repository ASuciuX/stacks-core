## steps to reproduce working version with same number lines:

from the root of the repository

```bash
cd mutation-testing/scripts
sh append.sh
# can see on git how the trails folder files were modified
git status ./..
```

## steps to reproduce working version with different number lines:

in trials/mutants-stable/caught.txt replace line number 23 with 109
the append.sh won't work anymore
the append-match.sh

```bash
sh append-match.sh

```
