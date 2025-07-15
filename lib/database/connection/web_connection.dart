import 'package:drift/drift.dart';
import 'package:drift/web.dart';

/// Creates database connection for web platform using IndexedDB
LazyDatabase connect() {
  return LazyDatabase(() async {
    try {
      // Try to use IndexedDB storage first
      return WebDatabase.withStorage(
        DriftWebStorage.indexedDb('petrol_tracker_db'),
      );
    } catch (e) {
      // If IndexedDB fails or sql.js is required, fall back to in-memory
      // This provides a working database even if persistence isn't available
      return WebDatabase.withStorage(
        DriftWebStorage.volatile(),
      );
    }
  });
}