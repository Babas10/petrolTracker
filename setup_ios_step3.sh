#!/bin/bash
echo "🧪 Step 3: Testing iOS simulator setup..."

# Check Flutter iOS setup
echo "Checking Flutter iOS setup..."
flutter doctor

# List available devices
echo "📱 Available Flutter devices:"
flutter devices

# Set up iOS dependencies for the project
echo "Setting up iOS project dependencies..."
cd ios
pod install
cd ..

echo "🎉 Ready to run on iOS!"
echo ""
echo "To run your app on iOS simulator:"
echo "  flutter run -d ios"
echo ""
echo "To run on specific simulator:"
echo "  flutter run -d 'iPhone 15 Pro Simulator'"
echo ""
echo "To open Simulator app manually:"
echo "  open -a Simulator"