# iPhone Simulator Setup Guide for Petrol Tracker

This guide walks you through setting up the iPhone simulator on macOS and running the Petrol Tracker app for mobile testing.

## 📋 Prerequisites

- **macOS** (Intel or Apple Silicon)
- **Xcode** installed from the App Store
- **Flutter** development environment set up
- **Admin privileges** on your Mac (for some setup commands)

## 🔧 Initial Setup

### Step 1: Install Xcode Command Line Tools

First, ensure Xcode command line tools are properly configured:

```bash
# Check current developer tools path
xcode-select --print-path

# Switch to full Xcode installation (requires admin password)
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# Run first launch setup (requires admin password)
sudo xcodebuild -runFirstLaunch

# Accept Xcode license agreement
sudo xcodebuild -license accept
```

### Step 2: Install CocoaPods

CocoaPods is required for iOS dependencies:

```bash
# Install CocoaPods (requires admin password)
sudo gem install cocoapods
```

### Step 3: Install iOS Simulator Runtimes

You have two options to install iOS simulator runtimes:

#### Option A: Through Xcode (Recommended)
1. Open **Xcode** from Applications
2. Go to **Xcode → Settings** (or **Preferences** in older versions)
3. Click on the **Platforms** tab
4. Find **iOS** in the list and click the **GET** button
5. Wait for the download to complete (10-15 minutes depending on connection)

#### Option B: Command Line
```bash
# Install latest iOS runtime
xcrun simctl runtime --install iOS
```

### Step 4: Verify Setup

Check that everything is properly configured:

```bash
# Verify Flutter can see iOS development tools
flutter doctor

# Expected output should show:
# [✓] Xcode - develop for iOS and macOS (Xcode 16.x)
```

## 📱 Starting the iPhone Simulator

### Method 1: Using Flutter Commands

```bash
# List available simulators
flutter emulators

# List available devices (when simulators are running)
flutter devices

# Boot a specific iPhone model
xcrun simctl list devices
xcrun simctl boot "iPhone 16 Pro"
```

### Method 2: Using Xcode

1. Open **Xcode**
2. Go to **Window → Devices and Simulators**
3. Click the **Simulators** tab
4. Select your preferred iPhone model
5. Click the **Boot** button

### Method 3: Using Simulator App

```bash
# Open the Simulator app directly
open -a Simulator

# Or launch from command line with specific device
xcrun simctl boot "iPhone 16 Pro"
open -a Simulator
```

## 🚀 Running Petrol Tracker on iPhone Simulator

### Step 1: Start the Simulator

Choose your preferred iPhone model and start it:

```bash
# Boot iPhone 16 Pro (recommended for testing)
xcrun simctl boot "iPhone 16 Pro"
open -a Simulator
```

### Step 2: Run the App

Navigate to your Petrol Tracker project directory and run:

```bash
# Change to project directory
cd /path/to/petrolTracker

# Run on iPhone simulator
flutter run -d iPhone

# Or specify exact device ID if multiple simulators are running
flutter run -d "06BEA3F9-2D2F-4EAA-A759-53C5ADF5AC29"
```

### Step 3: Initial Build

The first iOS build will take longer (2-5 minutes) because Flutter needs to:
- Run `pod install` for iOS dependencies
- Compile the app for iOS
- Install on the simulator

You'll see output like:
```
Launching lib/main.dart on iPhone 16 Pro in debug mode...
Running pod install...                                             37.9s
Running Xcode build...                                           17.2s
Syncing files to device iPhone 16 Pro...                            84ms
```

## 📊 Testing the App Features

Once the app is running on the iPhone simulator, you can test:

### Core Navigation
- **Bottom Navigation Bar**: Tap between Dashboard, Entries, Add Entry, Vehicles, Settings
- **Touch Gestures**: All mouse interactions become touch gestures
- **Mobile Layout**: See how the app adapts to smaller screen sizes

### Dashboard Features
- **Welcome Card**: Overview section at the top
- **Quick Stats**: Vehicle and fuel entry statistics
- **Chart Sections**: Consumption charts and average consumption
- **New Cost Analysis Section**: Preview of spending statistics

### Cost Analysis Dashboard
1. **Navigate**: Tap "Full Analysis" button in the Cost Analysis section
2. **Test Mobile UI**: 
   - Vehicle selector dropdown
   - Time period buttons (1M, 6M, 1Y, All Time)
   - Country filtering (if multiple countries available)
3. **View Charts**:
   - Monthly spending breakdown
   - Country spending comparison
   - Price trends by country
   - Comprehensive statistics grid

### Multi-Country Testing
The app comes with comprehensive test data:
- **5 Vehicles**: Honda Civic, Toyota Hilux, BMW 320i, Toyota Prius, Mazda MX-5
- **6 Countries**: Canada, USA, Germany, Australia, Japan, France
- **120+ Entries**: Rich dataset for testing filtering and analysis

## 🔄 Development Workflow

### Hot Reload
While the app is running, you can make code changes and hot reload:

```bash
# Press 'r' in the terminal to hot reload
r

# Press 'R' for hot restart (full restart)
R

# Press 'q' to quit
q
```

### Multiple Simulators
You can run multiple simulators simultaneously:

```bash
# Boot multiple devices
xcrun simctl boot "iPhone 16 Pro"
xcrun simctl boot "iPad Pro 11-inch"

# List all running devices
flutter devices

# Run on specific device
flutter run -d "device-id-here"
```

## Available iPhone Models

Common iPhone simulators available:
- **iPhone 16 Pro** (Latest, recommended)
- **iPhone 16 Pro Max** (Large screen testing)
- **iPhone 16** (Standard size)
- **iPhone 15 Pro** (Previous generation)
- **iPhone SE** (Small screen testing)

## 🛠 Troubleshooting

### Common Issues

#### "Unable to get list of installed Simulator runtimes"
```bash
# Ensure Xcode developer tools are properly set
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

#### No simulators in list
- Open Xcode → Settings → Platforms
- Install iOS platform if not already installed

#### CocoaPods issues
```bash
# Update CocoaPods
sudo gem update cocoapods

# Clear pods cache
cd ios/
rm -rf Pods/
rm Podfile.lock
flutter clean
flutter run
```

#### Build errors
```bash
# Clean Flutter build
flutter clean

# Clean iOS build
cd ios/
rm -rf build/
cd ..

# Rebuild
flutter run -d iPhone
```

### Performance Tips

1. **Close unused simulators** to save memory
2. **Use iPhone 16 Pro** for best performance/feature balance
3. **Enable GPU acceleration** in simulator settings
4. **Allocate sufficient RAM** to the simulator in Xcode settings

## 🌐 API Testing on iOS Simulator

The Petrol Tracker app includes a REST API server for testing. When running on the iPhone simulator:

### API Server Details
- **Base URL**: `http://localhost:8080`
- **Status**: Auto-starts in debug mode (non-web platforms)
- **Documentation**: Available in console output when app starts

### Available API Endpoints
```
GET  /api/health              - Health check
GET  /api/vehicles            - List all vehicles
POST /api/vehicles            - Create new vehicle
DEL  /api/vehicles/{id}       - Delete vehicle by ID
GET  /api/fuel-entries        - List all fuel entries
POST /api/fuel-entries        - Create new fuel entry
DEL  /api/fuel-entries/{id}   - Delete fuel entry by ID
POST /api/bulk/vehicles       - Bulk create vehicles
POST /api/bulk/fuel-entries   - Bulk create fuel entries
POST /api/bulk/data           - Bulk create mixed data
DEL  /api/bulk/reset          - Clear all data
```

### Testing the API
You can test the API using curl, Postman, or any HTTP client:

```bash
# Health check
curl http://localhost:8080/api/health

# List all vehicles
curl http://localhost:8080/api/vehicles

# List all fuel entries
curl http://localhost:8080/api/fuel-entries

# Reset all data (useful for testing)
curl -X DELETE http://localhost:8080/api/bulk/reset
```

### Example API Responses
```json
// GET /api/vehicles
{
  "vehicles": [
    {
      "id": 1,
      "name": "Honda Civic 2020",
      "initialKm": 45200.0,
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ]
}

// GET /api/fuel-entries
{
  "entries": [
    {
      "id": 1,
      "vehicleId": 1,
      "date": "2024-01-15",
      "currentKm": 45250.5,
      "fuelAmount": 35.2,
      "price": 54.60,
      "country": "Canada",
      "pricePerLiter": 1.55,
      "consumption": 7.2
    }
  ]
}
```

### Network Access
- The API server runs on `localhost:8080` and is accessible from your Mac
- The iOS simulator shares the same network as your Mac
- Use `localhost` or `127.0.0.1` to connect to the API server
- Make sure no firewall is blocking port 8080

## 📚 Additional Resources

- [Flutter iOS Setup Documentation](https://docs.flutter.dev/get-started/install/macos/mobile-ios)
- [Xcode Simulator User Guide](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)
- [iOS Simulator Keyboard Shortcuts](https://developer.apple.com/documentation/xcode/interacting-with-the-ios-simulator)

## 🎯 Quick Start Summary

For a quick setup after initial installation:

```bash
# 1. Start simulator
xcrun simctl boot "iPhone 16 Pro"
open -a Simulator

# 2. Run app
cd /path/to/petrolTracker
flutter run -d iPhone

# 3. Test features
# - Navigate through bottom tabs
# - Test cost analysis dashboard
# - Try time period filtering
# - Test multi-country data analysis
```

The iPhone simulator provides an excellent way to test the mobile user experience of the Petrol Tracker app, especially the new cost analysis features with time period filtering and multi-country spending analysis.