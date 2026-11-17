#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

command -v xcrun >/dev/null || { echo "需要在 macOS 上运行，并安装 Xcode Command Line Tools"; exit 1; }
SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
mkdir -p build dist

clang -target arm64-apple-ios16.0 -fobjc-arc -fblocks -Os \
  -isysroot "$SDK" -c tweak/HBOriginalImage.m -o build/HBOriginalImage.o

clang -target arm64-apple-ios16.0 -dynamiclib -nostdlib \
  -L"$SDK/usr/lib" -lSystem -Wl,-undefined,dynamic_lookup \
  -Wl,-install_name,@executable_path/Frameworks/HBOriginalImage.dylib \
  build/HBOriginalImage.o -o dist/HBOriginalImage.dylib

codesign -s - --force --timestamp=none dist/HBOriginalImage.dylib
file dist/HBOriginalImage.dylib
shasum -a 256 dist/HBOriginalImage.dylib
echo "构建完成：dist/HBOriginalImage.dylib"
