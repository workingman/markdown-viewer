#!/bin/zsh
set -e

rm -rf "/Applications/Markdown Viewer.app"
cp -R ~/Library/Developer/Xcode/DerivedData/Markdown_Viewer-govdmulhoajqxfctntjklufxojdb/Build/Products/Debug/Markdown\ Viewer.app /Applications/
codesign --force --deep --sign - "/Applications/Markdown Viewer.app"

echo "Installed successfully."
