#!/bin/bash

cd $(dirname "$BASH_SOURCE")
git add .
git status
git commit -m 'Daliy Auto BackUp'
git push
