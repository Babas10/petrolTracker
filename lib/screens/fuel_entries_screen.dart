import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petrol_tracker/navigation/main_layout.dart';

/// Fuel entries screen displaying list of all fuel entries
/// 
/// This screen will eventually show:
/// - List of fuel entries with filtering and sorting
/// - Search functionality
/// - Entry details and actions
/// - Export functionality
class FuelEntriesScreen extends StatefulWidget {
  const FuelEntriesScreen({super.key});

  @override
  State<FuelEntriesScreen> createState() => _FuelEntriesScreenState();
}

class _FuelEntriesScreenState extends State<FuelEntriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'date';
  bool _ascending = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavAppBar(
        title: 'Fuel Entries',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                if (value == _sortBy) {
                  _ascending = !_ascending;
                } else {
                  _sortBy = value;
                  _ascending = true;
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today),
                    SizedBox(width: 8),
                    Text('Sort by Date'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'amount',
                child: Row(
                  children: [
                    Icon(Icons.local_gas_station),
                    SizedBox(width: 8),
                    Text('Sort by Amount'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cost',
                child: Row(
                  children: [
                    Icon(Icons.attach_money),
                    SizedBox(width: 8),
                    Text('Sort by Cost'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: const Column(
        children: [
          _FilterChips(),
          Expanded(child: _EntriesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-entry'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Entries'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by vehicle, location, etc.',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement search functionality
              Navigator.of(context).pop();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}

/// Filter chips for quick filtering options
class _FilterChips extends StatefulWidget {
  const _FilterChips();

  @override
  State<_FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<_FilterChips> {
  String? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('all', 'All Entries'),
      ('thisWeek', 'This Week'),
      ('thisMonth', 'This Month'),
      ('thisYear', 'This Year'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter.$2),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? filter.$1 : null;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// List of fuel entries
class _EntriesList extends StatelessWidget {
  const _EntriesList();

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual entries from provider
    final hasEntries = false;

    if (!hasEntries) {
      return const _EmptyEntriesState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 0, // TODO: Replace with actual count
      itemBuilder: (context, index) {
        // TODO: Replace with actual entry widget
        return const SizedBox.shrink();
      },
    );
  }
}

/// Empty state when no entries exist
class _EmptyEntriesState extends StatelessWidget {
  const _EmptyEntriesState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_gas_station_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No Fuel Entries Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start tracking your fuel consumption by adding your first entry.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/add-entry'),
              icon: const Icon(Icons.add),
              label: const Text('Add First Entry'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.go('/vehicles'),
              icon: const Icon(Icons.directions_car),
              label: const Text('Add Vehicle First'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual fuel entry card widget
class _FuelEntryCard extends StatelessWidget {
  const _FuelEntryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.local_gas_station,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: const Text('Vehicle Name'), // TODO: Replace with actual data
        subtitle: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: Jan 15, 2024'), // TODO: Replace with actual date
            Text('Amount: 45.2L • Cost: \$68.50'), // TODO: Replace with actual data
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                // TODO: Navigate to edit screen
                break;
              case 'delete':
                // TODO: Show delete confirmation
                break;
            }
          },
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
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to entry details or edit screen
        },
      ),
    );
  }
}