#!/bin/sh
set -eu
cd "$(dirname "$0")"
clang++ -std=c++17 -O2 -arch arm64 -fobjc-arc -framework Cocoa -x objective-c++ CatMon.mm -o CatMon-MChip
printf 'Built CatMon-MChip (macOS ARM64)\n'
