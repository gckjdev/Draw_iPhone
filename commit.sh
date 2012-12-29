#!/bin/bash

echo 'add files'
git add *.h *.m *.xib *.strings *.plist *.png *.jpg *.txt *.sh *.pbxproj

echo 'checkout unuse files'
git checkout *.xcuserstate *DS_Store

echo 'commit files. Comment:'"$1"
git commit -m "$1"

echo 'pull'
git pull

echo 'push'
git push
