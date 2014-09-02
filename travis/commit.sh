#! /usr/bin/env sh
# 2
# Commits the ./public dir

BUILD_DIR="./public"

git checkout -b gh-pages
# Stage the public dir and stash it
git add -f $BUILD_DIR
git stash
# Delete everything except .git
rm -rf ./*
rm .travis.yml
rm .gitignore
# Pop the public dir back into our working dir and move it's contents up into ./
git stash pop
mv $BUILD_DIR/* .
rm -r $BUILD_DIR
# Commit the static files that were in ./public, now at ./
git add -A
git commit --allow-empty-message -am ''