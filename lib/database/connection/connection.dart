import 'package:drift/drift.dart';

import 'connection_stub.dart'
    if (dart.library.ffi) 'native_connection.dart'
    if (dart.library.html) 'web_connection.dart';

/// Creates and configures the database connection
LazyDatabase openConnection() => connect();