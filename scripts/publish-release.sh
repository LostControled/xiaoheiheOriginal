#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v gh >/dev/null; then
  echo "缺少 GitHub CLI：brew install gh"
  exit 1
fi
gh auth status >/dev/null || { echo "请先运行 gh auth login"; exit 1; }

TAG="${1:-v1.0.0}"
bash scripts/build-dylib.sh
mkdir -p dist
(
  cd dist
  zip -9 -q "HBOriginalImage-${TAG}-iOS16-arm64.zip" HBOriginalImage.dylib
)

gh release create "$TAG" \
  "dist/HBOriginalImage-${TAG}-iOS16-arm64.zip" \
  --title "小黑盒自动原图插件 $TAG" \
  --notes "iOS 16.3.1 / arm64。通过 TrollFools 注入小黑盒。源码与构建说明见仓库 README。"

echo "Release 已发布：$TAG"
