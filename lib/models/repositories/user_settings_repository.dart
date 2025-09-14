import 'package:drift/drift.dart';
import 'package:petrol_tracker/database/database.dart';
import 'package:petrol_tracker/models/user_settings_model.dart';

/// Repository for managing user settings data
class UserSettingsRepository {
  final AppDatabase _database;

  UserSettingsRepository(this._database);

  /// Get the current user settings (single row expected)
  Future<UserSettingsModel?> getCurrentSettings() async {
    try {
      final settings = await (_database.select(_database.userSettings).get());
      if (settings.isEmpty) return null;
      return UserSettingsModel.fromEntity(settings.first);
    } catch (e) {
      throw Exception('Failed to get user settings: $e');
    }
  }

  /// Create initial user settings with default values
  Future<UserSettingsModel> createDefaultSettings({String primaryCurrency = 'USD'}) async {
    try {
      final settingsModel = UserSettingsModel.create(primaryCurrency: primaryCurrency);
      
      final id = await _database.into(_database.userSettings).insert(
        settingsModel.toCompanion(),
      );
      
      return settingsModel.copyWith(id: id);
    } catch (e) {
      throw Exception('Failed to create user settings: $e');
    }
  }

  /// Update user settings (or create if none exist)
  Future<UserSettingsModel> updateSettings(UserSettingsModel settings) async {
    try {
      final existingSettings = await getCurrentSettings();
      
      if (existingSettings == null) {
        // Create new settings
        return await createDefaultSettings(primaryCurrency: settings.primaryCurrency);
      } else {
        // Update existing settings
        final updatedSettings = settings.copyWith(
          id: existingSettings.id,
          createdAt: existingSettings.createdAt, // Preserve creation date
        );
        
        await _database.update(_database.userSettings).replace(
          updatedSettings.toUpdateCompanion(),
        );
        
        return updatedSettings;
      }
    } catch (e) {
      throw Exception('Failed to update user settings: $e');
    }
  }

  /// Update primary currency only
  Future<UserSettingsModel> updatePrimaryCurrency(String newCurrency) async {
    try {
      final currentSettings = await getCurrentSettings();
      
      if (currentSettings == null) {
        return await createDefaultSettings(primaryCurrency: newCurrency);
      }
      
      final updatedSettings = currentSettings.withPrimaryCurrency(newCurrency);
      return await updateSettings(updatedSettings);
    } catch (e) {
      throw Exception('Failed to update primary currency: $e');
    }
  }

  /// Get the current primary currency (returns 'USD' as default)
  Future<String> getPrimaryCurrency() async {
    try {
      final settings = await getCurrentSettings();
      return settings?.primaryCurrency ?? 'USD';
    } catch (e) {
      // If there's an error, return default currency
      return 'USD';
    }
  }

  /// Ensure user settings exist (create with defaults if not)
  Future<UserSettingsModel> ensureSettingsExist() async {
    try {
      final settings = await getCurrentSettings();
      if (settings != null) {
        return settings;
      }
      
      return await createDefaultSettings();
    } catch (e) {
      throw Exception('Failed to ensure settings exist: $e');
    }
  }

  /// Delete all user settings (for testing/reset)
  Future<void> clearSettings() async {
    try {
      await _database.delete(_database.userSettings).go();
    } catch (e) {
      throw Exception('Failed to clear user settings: $e');
    }
  }

  /// Watch for changes to user settings
  Stream<UserSettingsModel?> watchSettings() {
    return _database.select(_database.userSettings).watchSingleOrNull().map(
      (setting) => setting != null ? UserSettingsModel.fromEntity(setting) : null,
    );
  }

  /// Watch for changes to primary currency specifically
  Stream<String> watchPrimaryCurrency() {
    return watchSettings().map((settings) => settings?.primaryCurrency ?? 'USD');
  }
}