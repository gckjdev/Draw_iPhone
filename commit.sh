#!/bin/bash

echo '=========== add files (*.h *.m *.xib *.strings *.plist *.png *.jpg *.txt *.sh *.pbxproj)  ====================='
git add *.h *.m *.xib *.strings *.plist *.png *.jpg *.txt *.sh *.pbxproj
echo ''

echo '=========== auto checkout unuse files (*.xcuserstate *DS_Store)  ====='
git checkout *.xcuserstate *DS_Store
echo ''

echo '========== oh, commit files. Comment:'"$1"" ====================="
git commit -m "$1"
echo ''

echo '========== hey, pull code from server ================================'
git pull
echo ''

echo '========== wow, push code to server =================================='
git push
echo '========== congratulations! hope there is no conflict! ==============='
echo ''
