import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petrol_tracker/main.dart';

void main() {
  testWidgets('Petrol Tracker app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PetrolTrackerApp());

    // Verify that the app title is displayed.
    expect(find.text('Petrol Tracker'), findsOneWidget);
    
    // Verify that the welcome message is displayed.
    expect(find.text('Welcome to Petrol Tracker'), findsOneWidget);
    
    // Verify that the fuel station icon is displayed.
    expect(find.byIcon(Icons.local_gas_station), findsOneWidget);
    
    // Verify that the project structure ready message is displayed.
    expect(find.text('Project Structure Ready'), findsOneWidget);
  });
}