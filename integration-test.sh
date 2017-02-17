#!/bin/bash
set +x

rm -rf tmp

git config user.email "test@test.com"
git config user.name "Test"

git init tmp --quiet
cd tmp

# setup merge driver
cat > .git/config <<- EOF
[merge "javaimport"]
        name = A custom merge driver for Java import statements
        driver = ../java-import-git-merge-driver %O %A %B
        recursive = text
EOF

echo "*.java merge=javaimport" >> .gitattributes

# setup test branches
cat > A.java <<- EOF
package p;

import a;
import d;
EOF

git add A.java
git commit -m "Initial commit" --quiet

git branch conflicting

cat > A.java <<- EOF
package p;

import a;
import b;
import d;
EOF

git add A.java
git commit -m "second on master" --quiet

git checkout conflicting --quiet

cat > A.java <<- EOF
package p;

import a;
import c;
import d;
EOF

git add A.java
git commit -m "second on conflicting" --quiet

git merge master conflicting --no-edit

mergeResult=$?
if [ $mergeResult -ne 0 ]; then
    echo "== FAILURE =="
    exit $mergeResult
fi

echo "== SUCCESS =="
cat A.java
