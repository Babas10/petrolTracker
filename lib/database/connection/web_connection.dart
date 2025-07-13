import 'package:drift/drift.dart';
import 'package:drift/web.dart';

/// Creates database connection for web platform using IndexedDB
LazyDatabase connect() {
  return LazyDatabase(() async {
    // Use IndexedDB for web storage
    return WebDatabase('petrol_tracker_db');
  });
}