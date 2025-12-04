#!/bin/bash

# Quick Setup Script for Android Emulator

echo "🚀 Setting up Android Emulator for Expense Tracker"
echo ""

# Check if Android SDK is installed
if [ ! -d "$HOME/Library/Android/sdk" ]; then
    echo "❌ Android SDK not found!"
    echo "Please install Android Studio first: https://developer.android.com/studio"
    exit 1
fi

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

echo "📱 Available Android Virtual Devices:"
$ANDROID_HOME/emulator/emulator -list-avds

echo ""
echo "If you see a device listed above, run it with:"
echo "  $ANDROID_HOME/emulator/emulator -avd <device_name> &"
echo ""
echo "If no devices are listed, create one in Android Studio:"
echo "  1. Open Android Studio"
echo "  2. Click 'More Actions' → 'Virtual Device Manager'"
echo "  3. Click '+ Create Device'"
echo "  4. Select 'Pixel 5' → Next"
echo "  5. Download and select a system image (e.g., API 33)"
echo "  6. Finish"
echo ""
echo "Then run: flutter run"
