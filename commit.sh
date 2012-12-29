#!/bin/bash

echo '=========== add files (*.h *.m *.xib *.strings *.plist *.png *.jpg *.txt *.sh *.pbxproj)  ====================='
git add *.h *.m *.xib *.strings *.plist *.png *.jpg *.txt *.sh *.pbxproj

echo '=========== auto checkout unuse files (*.xcuserstate *DS_Store)  ==================='
git checkout *.xcuserstate *DS_Store

echo '========== commit files. Comment:'"$1""==================="
git commit -m "$1"

echo '========== pull code from server ========================='
git pull

echo '========== push code to server ==========================='
git push
