import 'package:drift/drift.dart';
import 'package:drift/web.dart';

/// Creates database connection for web platform using IndexedDB
/// This approach avoids sql.js dependency entirely
LazyDatabase connect() {
  return LazyDatabase(() async {
    // Use IndexedDB storage directly - more reliable than sql.js on web
    final storage = DriftWebStorage.indexedDb('petrol_tracker_db');
    return WebDatabase.withStorage(storage);
  });
}