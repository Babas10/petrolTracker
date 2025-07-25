#!/bin/bash
echo "🚀 Setting up iOS Simulator for Flutter..."

# Set up Xcode command line tools
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# Install CocoaPods (iOS dependency manager)
sudo gem install cocoapods

# Accept Xcode license
sudo xcodebuild -license accept

# Install iOS simulators (latest iOS version)
xcrun simctl list runtimes

echo "✅ Setup complete! Now you can:"
echo "1. flutter devices (to see available simulators)"
echo "2. flutter run -d 'iPhone 15 Pro' (to run on simulator)"
echo "3. Or open Simulator app manually"

echo "📱 Available simulators will be listed by:"
echo "flutter devices"