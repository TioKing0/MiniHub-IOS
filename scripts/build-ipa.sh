#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Codemagic clones the GitHub repository. During the transition the complete
# Xcode project is stored in this ZIP, so unpack it when the .xcodeproj is not
# already present at repository root.
if [ ! -d "MiniHubIOS.xcodeproj" ]; then
  PACKAGE="MiniHub-IOS-Codemagic.zip"
  if [ ! -f "$PACKAGE" ]; then
    echo "ERROR: MiniHubIOS.xcodeproj and $PACKAGE are both missing." >&2
    exit 66
  fi
  echo "Extracting $PACKAGE..."
  EXTRACT_DIR="/tmp/minihub-codemagic-source"
  rm -rf "$EXTRACT_DIR"
  mkdir -p "$EXTRACT_DIR"
  /usr/bin/unzip -q "$PACKAGE" -d "$EXTRACT_DIR"

  PROJECT_PATH="$(find "$EXTRACT_DIR" -type d -name 'MiniHubIOS.xcodeproj' -print -quit)"
  if [ -z "$PROJECT_PATH" ]; then
    echo "ERROR: MiniHubIOS.xcodeproj was not found inside $PACKAGE." >&2
    find "$EXTRACT_DIR" -maxdepth 3 -print
    exit 66
  fi

  SOURCE_ROOT="$(dirname "$PROJECT_PATH")"
  echo "Using extracted project at: $SOURCE_ROOT"
  cd "$SOURCE_ROOT"
fi

if [ ! -f "MiniHubIOS.xcodeproj/project.pbxproj" ]; then
  echo "ERROR: project.pbxproj is missing." >&2
  exit 66
fi

rm -rf build
mkdir -p build

echo "Building MiniHub for iOS 9 / ARMv7..."
xcodebuild \
  -project MiniHubIOS.xcodeproj \
  -scheme MiniHubIOS \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  ARCHS=armv7 \
  ONLY_ACTIVE_ARCH=NO \
  IPHONEOS_DEPLOYMENT_TARGET=9.0 \
  build

APP="$(find build/DerivedData/Build/Products/Release-iphoneos -maxdepth 1 -name '*.app' -print -quit)"
if [ -z "$APP" ]; then
  echo "ERROR: MiniHub.app not found." >&2
  exit 1
fi

cp -R "$APP" build/MiniHub.app
mkdir -p build/Payload
cp -R "$APP" build/Payload/MiniHub.app
(cd build && /usr/bin/zip -qry MiniHub.ipa Payload)

if [ "$(pwd)" != "$ROOT" ]; then
  rm -rf "$ROOT/build"
  mkdir -p "$ROOT/build"
  cp -R build/MiniHub.app "$ROOT/build/MiniHub.app"
  cp build/MiniHub.ipa "$ROOT/build/MiniHub.ipa"
fi

echo "Generated: $ROOT/build/MiniHub.ipa"
