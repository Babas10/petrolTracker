import 'package:drift/drift.dart';
import 'package:drift/web.dart';

/// Creates database connection for web platform
/// Now with proper sql.js configuration in index.html
LazyDatabase connect() {
  return LazyDatabase(() async {
    // Use WebDatabase with sql.js (configured in index.html)
    // This provides proper SQLite functionality on web
    return WebDatabase('petrol_tracker_db');
  });
}