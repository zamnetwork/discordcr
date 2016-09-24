#!/bin/bash
set -euo pipefail

# First arg is the release name
RELEASE="${1:-}"

# Save current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# If we are releasing, and not on master
if [ -n "$RELEASE" -a "$CURRENT_BRANCH" != "master" ]; then
    # Error out
    echo "Cannot release from outside master!"
    exit 1
fi

# Generate docs
crystal doc

# Copy docs to temp dir
TEMPDIR=$(mktemp -d)
cp -a doc/. "$TEMPDIR"

# Change to github pages branch
git checkout gh-pages

# Remove old master docs
rm -Rf doc/master

# Copy docs as master
cp -a $TEMPDIR/. doc/master

# If this is a release, copy docs to release dir
[ -n "$RELEASE" ] && cp -a $TEMPDIR/. "doc/$RELEASE"

# Make git commit
git add -A
git commit -am "Update docs"

# Push commit
git push

# Switch back to previous branch
git checout "$CURRENT_BRANCH"
