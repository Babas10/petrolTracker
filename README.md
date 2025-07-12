# Petrol Tracker

A Flutter application for tracking vehicle fuel consumption with interactive D3.js charts.

## Overview

Petrol Tracker helps users monitor their vehicle's fuel efficiency by tracking fuel purchases and generating insightful charts. The app features D3.js-powered visualizations to analyze consumption patterns, price trends, and cost efficiency across different countries and time periods.

## Features (Planned)

- 🚗 **Vehicle Management**: Track multiple vehicles
- ⛽ **Fuel Entry Tracking**: Record fuel purchases with location and price
- 📊 **Interactive D3.js Charts**: 
  - Fuel consumption over time
  - Average consumption by period
  - Price trends by country
  - Cost analysis dashboard
- 📱 **Cross-Platform**: Android, iOS, and Web support
- 🌙 **Material Design 3**: Modern UI with light/dark theme support
- ☁️ **Cloud Sync**: Backup and sync across devices
- 📤 **Data Export**: CSV, PDF, and Excel export options

## Project Structure

```
lib/
├── models/          # Data models for vehicles, fuel entries
├── services/        # Business logic and API services
├── providers/       # State management (Riverpod)
├── screens/         # UI screens/pages
├── widgets/         # Reusable UI components
├── utils/           # Helper functions and constants
└── main.dart        # Application entry point

assets/
└── charts/          # D3.js chart files

docs/
├── issue-21-implementation.md  # Documentation for project setup
└── issue-23-implementation.md  # Documentation for data models and repositories
```

## Technology Stack

- **Framework**: Flutter 3.16+
- **State Management**: Riverpod
- **Database**: SQLite with Drift ORM
- **Charts**: D3.js via WebView
- **Navigation**: GoRouter
- **Design**: Material Design 3

## Getting Started

### Prerequisites

- Flutter SDK 3.16.0 or higher
- Dart SDK 3.8.1 or higher

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Babas10/petrolTracker.git
   cd petrolTracker
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Development

Run tests:
```bash
flutter test
```

Analyze code:
```bash
flutter analyze
```

## Development Progress

### ✅ Completed
- [x] Issue #21: Flutter project structure setup
- [x] Issue #22: SQLite database with Drift ORM
- [x] Issue #23: Data models and repositories
- [x] Material Design 3 theming
- [x] Basic app architecture
- [x] Database layer with error handling
- [x] Model layer with validation and business logic
- [x] Repository pattern implementation
- [x] Documentation foundation

### 🚧 In Progress
- [ ] Issue #24: Riverpod state management
- [ ] Issue #25: Navigation structure

### 📋 Planned
- [ ] Core features (Issues #1-5)
- [ ] D3.js chart integration (Issues #6-11)
- [ ] Advanced features (Issues #12-16)
- [ ] Polish and deployment (Issues #17-20)

## Contributing

1. Check the [GitHub Issues](https://github.com/Babas10/petrolTracker/issues) for planned work
2. Create a feature branch for your issue
3. Implement the feature with tests
4. Submit a pull request with documentation

## Documentation

- [Issue #21 Implementation](docs/issue-21-implementation.md) - Project setup details
- [Issue #22 Implementation](docs/issue-22-implementation.md) - SQLite database configuration
- [Issue #23 Implementation](docs/issue-23-implementation.md) - Data models and repositories

## License

This project is private and not licensed for public use.

## Contact

For questions or suggestions, please open an issue on GitHub.