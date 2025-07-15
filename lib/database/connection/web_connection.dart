import 'package:drift/drift.dart';
import 'package:drift/web.dart';

/// Creates database connection for web platform using IndexedDB
LazyDatabase connect() {
  return LazyDatabase(() async {
    // Use IndexedDB for web storage - this is more reliable than sql.js
    // and doesn't require additional JavaScript libraries
    return WebDatabase.withStorage(
      DriftWebStorage.indexedDb('petrol_tracker_db'),
    );
  });
}