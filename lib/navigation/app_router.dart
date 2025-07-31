import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petrol_tracker/navigation/main_layout.dart';
import 'package:petrol_tracker/screens/dashboard_screen.dart';
import 'package:petrol_tracker/screens/fuel_entries_screen.dart';
import 'package:petrol_tracker/screens/add_fuel_entry_screen.dart';
import 'package:petrol_tracker/screens/vehicles_screen.dart';
import 'package:petrol_tracker/screens/settings_screen.dart';
import 'package:petrol_tracker/screens/fuel_consumption_chart_screen.dart';
import 'package:petrol_tracker/screens/average_consumption_chart_screen.dart';
import 'package:petrol_tracker/screens/cost_analysis_dashboard_screen.dart';

/// Application router configuration using go_router
/// 
/// Implements a shell route pattern with bottom navigation bar
/// and deep linking support for all main application screens.
final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/entries',
          name: 'entries',
          builder: (context, state) => const FuelEntriesScreen(),
        ),
        GoRoute(
          path: '/add-entry',
          name: 'add-entry',
          builder: (context, state) => const AddFuelEntryScreen(),
        ),
        GoRoute(
          path: '/vehicles',
          name: 'vehicles',
          builder: (context, state) => const VehiclesScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/consumption-chart',
          name: 'consumption-chart',
          builder: (context, state) => const FuelConsumptionChartScreen(),
        ),
        GoRoute(
          path: '/average-consumption-chart',
          name: 'average-consumption-chart',
          builder: (context, state) => const AverageConsumptionChartScreen(),
        ),
        GoRoute(
          path: '/cost-analysis',
          name: 'cost-analysis',
          builder: (context, state) => const CostAnalysisDashboardScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(
      title: const Text('Page Not Found'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Page Not Found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'The page "${state.uri}" does not exist.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    ),
  ),
);

/// Navigation routes configuration
enum AppRoute {
  dashboard('/'),
  entries('/entries'),
  addEntry('/add-entry'),
  vehicles('/vehicles'),
  settings('/settings'),
  consumptionChart('/consumption-chart'),
  averageConsumptionChart('/average-consumption-chart');

  const AppRoute(this.path);
  final String path;
}