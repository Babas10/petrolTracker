#!/bin/bash
echo "🏃‍♂️ Step 2: Setting up iOS simulators and dependencies..."

# Run first launch to install additional components
echo "Installing Xcode additional components..."
sudo xcodebuild -runFirstLaunch

# Install CocoaPods (iOS dependency manager)
echo "Installing CocoaPods..."
sudo gem install cocoapods

# Check iOS simulators
echo "📱 Available iOS simulators:"
xcrun simctl list devices available

echo "✅ iOS setup complete!"
echo "Next: Run ./setup_ios_step3.sh to test"