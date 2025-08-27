import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petrol_tracker/navigation/main_layout.dart';
import 'package:petrol_tracker/models/maintenance_category_model.dart';
import 'package:petrol_tracker/providers/maintenance_providers.dart';

/// Maintenance categories management screen
/// 
/// Features:
/// - List all maintenance categories (system and custom)
/// - Add new custom categories
/// - Edit custom categories (system ones are read-only)
/// - Delete custom categories
/// - Visual category preview with icons and colors
/// - Color picker for category customization
/// - Icon selection for category representation
class MaintenanceCategoriesScreen extends ConsumerStatefulWidget {
  const MaintenanceCategoriesScreen({super.key});

  @override
  ConsumerState<MaintenanceCategoriesScreen> createState() => _MaintenanceCategoriesScreenState();
}

class _MaintenanceCategoriesScreenState extends ConsumerState<MaintenanceCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(maintenanceCategoriesProvider);

    return Scaffold(
      appBar: NavAppBar(
        title: 'Maintenance Categories',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(maintenanceCategoriesProvider),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) => _buildCategoriesList(categories),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
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
                'Failed to load categories',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(maintenanceCategoriesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Add Category',
      ),
    );
  }

  Widget _buildCategoriesList(List<MaintenanceCategoryModel> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No categories found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first maintenance category',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddCategoryDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
            ),
          ],
        ),
      );
    }

    // Separate system and custom categories
    final systemCategories = categories.where((c) => c.isSystem).toList();
    final customCategories = categories.where((c) => !c.isSystem).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (systemCategories.isNotEmpty) ...[
          Text(
            'System Categories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            'Built-in categories that cannot be modified',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          ...systemCategories.map((category) => _buildCategoryCard(category, isEditable: false)),
          const SizedBox(height: 24),
        ],
        if (customCategories.isNotEmpty) ...[
          Text(
            'Custom Categories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            'Categories you\'ve created and can modify',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          ...customCategories.map((category) => _buildCategoryCard(category, isEditable: true)),
        ],
        if (customCategories.isEmpty && systemCategories.isNotEmpty) ...[
          Text(
            'Custom Categories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            'You haven\'t created any custom categories yet',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              title: Text(
                'Add Custom Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              subtitle: Text(
                'Create your own maintenance categories',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              onTap: () => _showAddCategoryDialog(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryCard(MaintenanceCategoryModel category, {required bool isEditable}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.colorValue.withOpacity(0.2),
          child: Icon(
            category.icon,
            color: category.colorValue,
            size: 20,
          ),
        ),
        title: Text(
          category.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: category.colorValue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              category.color,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 12),
            if (category.isSystem)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'SYSTEM',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
          ],
        ),
        trailing: isEditable ? PopupMenuButton<String>(
          onSelected: (action) => _handleCategoryAction(action, category),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ) : Icon(
          Icons.lock,
          color: Theme.of(context).colorScheme.outline,
          size: 20,
        ),
        onTap: isEditable ? () => _showEditCategoryDialog(category) : null,
      ),
    );
  }

  void _handleCategoryAction(String action, MaintenanceCategoryModel category) {
    switch (action) {
      case 'edit':
        _showEditCategoryDialog(category);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(category);
        break;
    }
  }

  void _showAddCategoryDialog() {
    _showCategoryDialog();
  }

  void _showEditCategoryDialog(MaintenanceCategoryModel category) {
    _showCategoryDialog(existingCategory: category);
  }

  void _showCategoryDialog({MaintenanceCategoryModel? existingCategory}) {
    final nameController = TextEditingController(text: existingCategory?.name ?? '');
    String selectedColor = existingCategory?.color ?? '#4CAF50';
    String selectedIconName = existingCategory?.iconName ?? 'build';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existingCategory != null ? 'Edit Category' : 'Add Category'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Color: ',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(width: 8),
                    ..._getColorOptions().map((color) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedColor = color),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                            shape: BoxShape.circle,
                            border: selectedColor == color
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Icon: ',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(width: 8),
                    ..._getIconOptions().take(6).map((iconData) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedIconName = _getIconName(iconData)),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: selectedIconName == _getIconName(iconData)
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                              : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            iconData,
                            color: selectedIconName == _getIconName(iconData)
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Preview: ', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Color(int.parse(selectedColor.replaceFirst('#', '0xFF'))).withOpacity(0.2),
                      child: Icon(
                        _getIconFromName(selectedIconName),
                        color: Color(int.parse(selectedColor.replaceFirst('#', '0xFF'))),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(nameController.text.isNotEmpty ? nameController.text : 'Category Name'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _saveCategory(
                existingCategory,
                nameController.text.trim(),
                selectedColor,
                selectedIconName,
              ),
              child: Text(existingCategory != null ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getColorOptions() {
    return [
      '#4CAF50', // Green
      '#2196F3', // Blue  
      '#FF5722', // Deep Orange
      '#FFC107', // Amber
      '#9C27B0', // Purple
      '#F44336', // Red
      '#607D8B', // Blue Grey
      '#795548', // Brown
      '#00BCD4', // Cyan
      '#757575', // Grey
    ];
  }

  List<IconData> _getIconOptions() {
    return [
      Icons.build,
      Icons.car_repair,
      Icons.settings,
      Icons.electrical_services,
      Icons.local_car_wash,
      Icons.filter_alt,
      Icons.speed,
      Icons.tire_repair,
      Icons.search,
      Icons.cleaning_services,
    ];
  }

  String _getIconName(IconData iconData) {
    switch (iconData.codePoint) {
      case 0xe145: return 'build';
      case 0xe1e5: return 'car_repair';
      case 0xe8b8: return 'settings';
      case 0xe912: return 'electrical_services';
      case 0xe1e6: return 'local_car_wash';
      case 0xe3e3: return 'filter_alt';
      case 0xe9e4: return 'speed';
      case 0xf0d3: return 'tire_repair';
      case 0xe8b6: return 'search';
      case 0xe1a4: return 'cleaning_services';
      default: return 'build';
    }
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'local_car_wash': return Icons.local_car_wash;
      case 'filter_alt': return Icons.filter_alt;
      case 'settings': return Icons.settings;
      case 'electrical_services': return Icons.electrical_services;
      case 'tire_repair': return Icons.tire_repair;
      case 'speed': return Icons.speed;
      case 'car_repair': return Icons.car_repair;
      case 'search': return Icons.search;
      case 'cleaning_services': return Icons.cleaning_services;
      case 'build': return Icons.build;
      default: return Icons.build;
    }
  }

  Future<void> _saveCategory(
    MaintenanceCategoryModel? existingCategory,
    String name,
    String color,
    String iconName,
  ) async {
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    try {
      if (existingCategory != null) {
        // Update existing category
        final updatedCategory = existingCategory.copyWith(
          name: name,
          color: color,
          iconName: iconName,
        );
        final notifier = ref.read(maintenanceCategoriesNotifierProvider.notifier);
        await notifier.updateCategory(updatedCategory);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Add new category
        final newCategory = MaintenanceCategoryModel(
          name: name,
          iconName: iconName,
          color: color,
          isSystem: false,
          createdAt: DateTime.now(),
        );
        
        final notifier = ref.read(maintenanceCategoriesNotifierProvider.notifier);
        await notifier.addCategory(newCategory);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.of(context).pop();
      ref.refresh(maintenanceCategoriesProvider);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save category: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog(MaintenanceCategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete the category "${category.name}"?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteCategory(category),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(MaintenanceCategoryModel category) async {
    try {
      final notifier = ref.read(maintenanceCategoriesNotifierProvider.notifier);
      await notifier.deleteCategory(category.id!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
      ref.refresh(maintenanceCategoriesProvider);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete category: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}