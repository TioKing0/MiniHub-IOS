#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
rm -rf build
mkdir -p build
xcodebuild -project MiniHubIOS.xcodeproj -scheme MiniHubIOS -configuration Release -sdk iphoneos -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" ARCHS=armv7 ONLY_ACTIVE_ARCH=NO IPHONEOS_DEPLOYMENT_TARGET=9.0 build
APP="$(find build/DerivedData/Build/Products/Release-iphoneos -maxdepth 1 -name '*.app' -print -quit)"
if [ -z "$APP" ]; then echo "MiniHub.app não encontrado" >&2; exit 1; fi
cp -R "$APP" build/MiniHub.app
mkdir -p build/Payload
cp -R "$APP" build/Payload/MiniHub.app
(cd build && /usr/bin/zip -qry MiniHub.ipa Payload)
echo "Gerado: $ROOT/build/MiniHub.ipa"
