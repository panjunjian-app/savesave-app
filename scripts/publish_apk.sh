#!/usr/bin/env bash
# 发布 Android 新版本到 Cloudflare Pages（应用内更新的下载源）。
#
# 用法：scripts/publish_apk.sh [产物目录]
#   - 默认读取 build/app/outputs/flutter-apk/
#   - 自动挑选 arm64 包（覆盖 99% 机型），写入 sha256 与体积
#   - 生成 build/web/apk/latest.json 供 App 端 /apk/latest.json 读取
#
# 前置：已执行 flutter build web --release 与 flutter build apk --release --split-per-abi
set -euo pipefail

cd "$(dirname "$0")/.."

APK_DIR="${1:-build/app/outputs/flutter-apk}"
APK_SRC="$APK_DIR/app-arm64-v8a-release.apk"
WEB_DIR="build/web"
APK_DEST="$WEB_DIR/apk"

if [ ! -f "$APK_SRC" ]; then
  echo "❌ 找不到 $APK_SRC，请先执行 flutter build apk --release --split-per-abi" >&2
  exit 1
fi
if [ ! -d "$WEB_DIR" ]; then
  echo "❌ 找不到 $WEB_DIR，请先执行 flutter build web --release" >&2
  exit 1
fi

AAPT="$HOME/android-sdk/build-tools/36.0.0/aapt"
VERSION_CODE=$("$AAPT" dump badging "$APK_SRC" | sed -n "s/.*versionCode='\([0-9]*\)'.*/\1/p" | head -1)
VERSION_NAME=$("$AAPT" dump badging "$APK_SRC" | sed -n "s/.*versionName='\([^']*\)'.*/\1/p" | head -1)
SIZE_BYTES=$(stat -f %z "$APK_SRC")
SHA256=$(shasum -a 256 "$APK_SRC" | awk '{print $1}')
NOTES="${NOTES:-修复与优化}"

mkdir -p "$APK_DEST"
cp "$APK_SRC" "$APK_DEST/savesave-android.apk"

cat > "$APK_DEST/latest.json" <<JSON
{
  "platform": "android",
  "versionCode": $VERSION_CODE,
  "versionName": "$VERSION_NAME",
  "apkUrl": "https://savesave.pages.dev/apk/savesave-android.apk",
  "sizeBytes": $SIZE_BYTES,
  "sha256": "$SHA256",
  "notes": "$NOTES",
  "force": false,
  "publishedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
JSON

echo "✅ 已准备应用内更新包"
echo "   versionName: $VERSION_NAME (versionCode $VERSION_CODE)"
echo "   size: $SIZE_BYTES bytes"
echo "   sha256: $SHA256"
echo "   manifest: $APK_DEST/latest.json"
