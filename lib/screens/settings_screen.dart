import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/navigation/main_layout.dart';
import 'package:petrol_tracker/providers/theme_providers.dart';
import 'package:petrol_tracker/providers/units_providers.dart';

/// Settings screen for app preferences and configuration
/// 
/// This screen provides:
/// - Theme settings (light/dark/system) with real-time switching
/// - Units preferences (metric/imperial)
/// - Data management options
/// - App information and version
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _analyticsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavAppBar(
        title: 'Settings',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAppearanceSection(),
          const SizedBox(height: 24),
          _buildUnitsSection(),
          const SizedBox(height: 24),
          _buildNotificationsSection(),
          const SizedBox(height: 24),
          _buildDataSection(),
          const SizedBox(height: 24),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    final currentTheme = ref.watch(themeModeProvider);
    
    return _SettingsSection(
      title: 'Appearance',
      icon: Icons.palette_outlined,
      children: [
        ListTile(
          title: const Text('Theme'),
          subtitle: Text(currentTheme.when(
            data: (theme) => theme.displayName,
            loading: () => 'Loading...',
            error: (_, __) => 'System',
          )),
          trailing: currentTheme.when(
            data: (currentMode) => DropdownButton<AppThemeMode>(
              value: currentMode,
              underline: const SizedBox(),
              items: AppThemeMode.values.map((mode) => DropdownMenuItem(
                value: mode,
                child: Text(mode.displayName),
              )).toList(),
              onChanged: (newMode) async {
                if (newMode != null) {
                  // Show immediate visual feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Switched to ${newMode.displayName} theme'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  
                  // Apply theme change
                  await ref.read(themeModeProvider.notifier).setThemeMode(newMode);
                }
              },
            ),
            loading: () => const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => const Icon(Icons.error_outline, color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitsSection() {
    final currentUnits = ref.watch(unitsProvider);
    
    return _SettingsSection(
      title: 'Units',
      icon: Icons.straighten_outlined,
      children: [
        ListTile(
          title: const Text('Unit System'),
          subtitle: Text(currentUnits.when(
            data: (units) => '${units.displayName} (${units.shortDescription})',
            loading: () => 'Loading...',
            error: (_, __) => 'Metric (L/100km, km, L)',
          )),
          trailing: currentUnits.when(
            data: (currentUnitSystem) => DropdownButton<UnitSystem>(
              value: currentUnitSystem,
              underline: const SizedBox(),
              items: UnitSystem.values.map((system) => DropdownMenuItem(
                value: system,
                child: Text(system.displayName),
              )).toList(),
              onChanged: (newSystem) async {
                if (newSystem != null) {
                  // Show immediate visual feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Switched to ${newSystem.displayName} units'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  
                  // Apply units change
                  await ref.read(unitsProvider.notifier).setUnitSystem(newSystem);
                }
              },
            ),
            loading: () => const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => const Icon(Icons.error_outline, color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return _SettingsSection(
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      children: [
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Get reminders for fuel entries'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
            // TODO: Handle notification settings
          },
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return _SettingsSection(
      title: 'Data Management',
      icon: Icons.storage_outlined,
      children: [
        ListTile(
          title: const Text('Export Data'),
          subtitle: const Text('Export your fuel data to CSV'),
          leading: const Icon(Icons.download_outlined),
          onTap: _exportData,
        ),
        ListTile(
          title: const Text('Import Data'),
          subtitle: const Text('Import fuel data from CSV'),
          leading: const Icon(Icons.upload_outlined),
          onTap: _importData,
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Anonymous Analytics'),
          subtitle: const Text('Help improve the app by sharing anonymous usage data'),
          value: _analyticsEnabled,
          onChanged: (value) {
            setState(() {
              _analyticsEnabled = value;
            });
            // TODO: Handle analytics settings
          },
        ),
        const Divider(),
        ListTile(
          title: const Text('Clear All Data'),
          subtitle: const Text('Permanently delete all your data'),
          leading: Icon(Icons.delete_forever_outlined, color: Theme.of(context).colorScheme.error),
          textColor: Theme.of(context).colorScheme.error,
          onTap: _showClearDataDialog,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _SettingsSection(
      title: 'About',
      icon: Icons.info_outlined,
      children: [
        const ListTile(
          title: Text('Version'),
          subtitle: Text('1.0.0'),
          leading: Icon(Icons.app_settings_alt_outlined),
        ),
        ListTile(
          title: const Text('Privacy Policy'),
          leading: const Icon(Icons.privacy_tip_outlined),
          onTap: () {
            // TODO: Show privacy policy
          },
        ),
        ListTile(
          title: const Text('Terms of Service'),
          leading: const Icon(Icons.description_outlined),
          onTap: () {
            // TODO: Show terms of service
          },
        ),
        ListTile(
          title: const Text('Open Source Licenses'),
          leading: const Icon(Icons.code_outlined),
          onTap: () {
            showLicensePage(
              context: context,
              applicationName: 'Petrol Tracker',
              applicationVersion: '1.0.0',
            );
          },
        ),
        ListTile(
          title: const Text('Rate App'),
          leading: const Icon(Icons.star_outline),
          onTap: () {
            // TODO: Open app store rating
          },
        ),
        ListTile(
          title: const Text('Send Feedback'),
          leading: const Icon(Icons.feedback_outlined),
          onTap: () {
            // TODO: Open feedback form
          },
        ),
      ],
    );
  }


  void _exportData() {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon!'),
      ),
    );
  }

  void _importData() {
    // TODO: Implement data import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Import functionality coming soon!'),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your vehicles, fuel entries, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  void _clearAllData() {
    // TODO: Implement data clearing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data clearing functionality coming soon!'),
      ),
    );
  }
}

/// Settings section widget for organizing related settings
class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(children: children),
        ),
      ],
    );
  }
}