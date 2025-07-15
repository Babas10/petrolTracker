import 'package:flutter/material.dart';
import 'package:petrol_tracker/app.dart';

/// Main entry point for the Petrol Tracker application
/// 
/// This function initializes the Flutter framework and starts the app
/// with proper initialization sequence handling.
void main() async {
  // Ensure Flutter framework is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start the application with initialization flow
  runApp(const PetrolTrackerApp());
}