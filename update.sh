#!bin/bash

# Update Version
VERSION=$(perl -pe 's/^((\d+\.)*)(\d+)(.*)$/$1.($3+1).$4/e' < version)
echo $VERSION > version

# Create Git Tag
git tag -a v$VERSION
git push origin --tags

eb deploy ceti-test-env
#git push

