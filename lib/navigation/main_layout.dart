import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petrol_tracker/navigation/app_router.dart';

/// Main layout widget that provides the bottom navigation structure
/// 
/// This widget wraps all main screens and provides consistent navigation
/// through a bottom navigation bar with 5 tabs.
class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

/// Bottom navigation bar widget with 5 tabs
/// 
/// Features:
/// - Dashboard tab (chart icon)
/// - Fuel Entries tab (list icon) 
/// - Add Entry tab (plus icon) - center prominent button
/// - Vehicles tab (car icon)
/// - Settings tab (settings icon)
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    
    return NavigationBar(
      selectedIndex: _calculateSelectedIndex(location),
      onDestinationSelected: (index) => _onItemTapped(index, context),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.list_outlined),
          selectedIcon: Icon(Icons.list),
          label: 'Entries',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle),
          label: 'Add Entry',
        ),
        NavigationDestination(
          icon: Icon(Icons.directions_car_outlined),
          selectedIcon: Icon(Icons.directions_car),
          label: 'Vehicles',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  /// Calculate the selected index based on current location
  int _calculateSelectedIndex(String location) {
    switch (location) {
      case '/':
        return 0;
      case '/entries':
        return 1;
      case '/add-entry':
        return 2;
      case '/vehicles':
        return 3;
      case '/settings':
        return 4;
      default:
        return 0;
    }
  }

  /// Handle navigation bar item tap
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoute.dashboard.path);
        break;
      case 1:
        context.go(AppRoute.entries.path);
        break;
      case 2:
        context.go(AppRoute.addEntry.path);
        break;
      case 3:
        context.go(AppRoute.vehicles.path);
        break;
      case 4:
        context.go(AppRoute.settings.path);
        break;
    }
  }
}

/// Custom app bar for navigation screens
/// 
/// Provides consistent styling and context-appropriate actions
/// for each screen in the application.
class NavAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const NavAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      leading: showBackButton 
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          )
        : leading,
      actions: actions,
      elevation: 0,
      scrolledUnderElevation: 1,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}