#!/bin/bash
echo "🔧 Step 1: Configuring Xcode for iOS development..."

# Check if Xcode is installed
if [ ! -d "/Applications/Xcode.app" ]; then
    echo "❌ Xcode not found! Please install Xcode from Mac App Store first."
    echo "Opening Mac App Store..."
    open "macappstore://apps.apple.com/app/xcode/id497799835"
    exit 1
fi

echo "✅ Xcode found! Configuring..."

# Set up Xcode command line tools to use the full Xcode
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# Accept Xcode license
sudo xcodebuild -license accept

echo "✅ Xcode configured successfully!"
echo "Next: Run ./setup_ios_step2.sh"