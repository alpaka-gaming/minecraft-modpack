#!/bin/bash

# Pack current directory as zip file
zip -r Alpaka-Modpack.mrpack src -x "*.git*" "node_modules/*" ".editorconfig" "build.sh" "build.ps1"

echo "Modpack packed"