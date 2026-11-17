#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
mkdir -p dist build

clang -target arm64-apple-ios16.0 -fobjc-arc -fblocks -Os \
  -isysroot "$SDK" -c tweak/HBOriginalImage.m -o build/HBOriginalImage.o

clang -target arm64-apple-ios16.0 -dynamiclib -nostdlib \
  -L"$SDK/usr/lib" -lSystem -Wl,-undefined,dynamic_lookup \
  -Wl,-install_name,@executable_path/Frameworks/HBOriginalImage.dylib \
  build/HBOriginalImage.o -o dist/HBOriginalImage.dylib

codesign -s - --force --timestamp=none dist/HBOriginalImage.dylib
file dist/HBOriginalImage.dylib
