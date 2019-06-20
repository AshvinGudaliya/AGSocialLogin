#!/bin/bash

cd $(dirname "$BASH_SOURCE")

git rm -r --cached .
git add .
git commit -am 'git cache cleared'
git push
