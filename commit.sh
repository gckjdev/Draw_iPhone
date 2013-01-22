#!/bin/bash

line=' ========= '
if [ -z "$1" ]; then
    echo "$line"" Commit message is empty. Can  not be comitted ""$line"
    exit 1
fi

echo ""
echo $line' add files (*.xcscheme *.h *.m *.xib *.strings *.plist *.png *.jpg *.txt *.sh *.pbxproj *.proto)  '$line
git add *.xcscheme *.proto *.h *.m *.xib *.strings *.plist *.png *.jpg *.txt *.sh *.pbxproj
echo ''

echo $line' auto checkout unuse files (*xcbkptlist *xcuserstate *DS_Store)  '$line
git checkout *xcbkptlist 
git checkout *xcuserstate 
git checkout *DS_Store
echo ''

echo $line' oh, commit files. comment: '"$@"" "$line
git commit -m "$@"
echo ''

echo $line' hey, pull code from server '$line
git pull
echo ''

echo $line' wow, push code to server '$line
git push

echo ''
echo $line' congratulations! hope there is no conflict! '$line
echo ''
