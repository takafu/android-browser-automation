#!/data/data/com.termux/files/usr/bin/bash

# Automated dev flow: Build -> Install -> Launch

set -e

APP_PACKAGE="io.github.takafu.webdroid"
APP_ACTIVITY="BrowserActivity"

echo "Building APK..."
gradle assembleDebug

echo "Installing APK via ADB..."
adb install -r app/build/outputs/apk/debug/app-debug.apk

echo "Launching app..."
adb shell am start -n "$APP_PACKAGE/.$APP_ACTIVITY"

echo ""
echo "================================"
echo "Done! Build -> Install -> Launch"
echo "================================"
echo ""
echo "View logs:"
echo "   adb logcat | grep -i '$APP_PACKAGE'"
echo ""
echo "Stop app:"
echo "   adb shell am force-stop $APP_PACKAGE"
