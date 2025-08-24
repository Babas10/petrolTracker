import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/providers/chart_providers.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:intl/intl.dart';

/// Modal dialog that shows detailed breakdown of a consumption period
class PeriodDetailModal extends ConsumerWidget {
  final EnhancedConsumptionDataPoint periodData;

  const PeriodDetailModal({
    super.key,
    required this.periodData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 700,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildContent(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                periodData.isComplexPeriod ? Icons.analytics : Icons.timeline,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Consumption Period Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${DateFormat('MMM d, y').format(periodData.periodStart)} - ${DateFormat('MMM d, y').format(periodData.periodEnd)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryStats(context),
          const SizedBox(height: 24),
          _buildFuelEntriesSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Period Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              context,
              'Fuel Consumption',
              '${periodData.consumption.toStringAsFixed(1)} L/100km',
              Icons.local_gas_station,
              Colors.green,
            ),
            _buildStatRow(
              context,
              'Total Distance',
              periodData.formattedDistance,
              Icons.route,
              Colors.green,
            ),
            _buildStatRow(
              context,
              'Total Fuel',
              periodData.formattedTotalFuel,
              Icons.opacity,
              Colors.indigo,
            ),
            _buildStatRow(
              context,
              'Total Cost',
              periodData.formattedTotalCost,
              Icons.attach_money,
              Colors.red,
            ),
            _buildStatRow(
              context,
              'Period Duration',
              periodData.formattedDuration,
              Icons.schedule,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFuelEntriesSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Fuel Entries (${periodData.totalEntries})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (periodData.partialEntries > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${periodData.partialEntries} partial',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEntriesTable(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildEntriesTable(BuildContext context, WidgetRef ref) {
    // Get the fuel entries for this period
    final entriesAsync = ref.watch(fuelEntriesNotifierProvider);
    
    return entriesAsync.when(
      data: (entriesState) {
        final periodEntries = entriesState.entries
            .where((entry) => periodData.entryIds.contains(entry.id))
            .toList();
        
        // Sort by date
        periodEntries.sort((a, b) => a.date.compareTo(b.date));
        
        return Column(
          children: [
            // Table header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 40), // Space for type indicator
                  Expanded(flex: 2, child: Text('Date', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold))),
                  Expanded(flex: 1, child: Text('Type', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold))),
                  Expanded(flex: 1, child: Text('Amount', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Odometer', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            // Table rows
            ...periodEntries.asMap().entries.map((entry) {
              final index = entry.key;
              final fuelEntry = entry.value;
              final isFirst = index == 0;
              final isLast = index == periodEntries.length - 1;
              
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? Colors.white : Colors.grey[50],
                  borderRadius: isLast ? const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ) : null,
                ),
                child: Row(
                  children: [
                    // Type indicator
                    Container(
                      width: 32,
                      height: 20,
                      decoration: BoxDecoration(
                        color: fuelEntry.isFullTank ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        fuelEntry.isFullTank ? Icons.circle : Icons.radio_button_unchecked,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Date
                    Expanded(
                      flex: 2,
                      child: Text(
                        DateFormat('MMM d').format(fuelEntry.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    // Type
                    Expanded(
                      flex: 1,
                      child: Text(
                        fuelEntry.isFullTank ? 'Full' : 'Partial',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: fuelEntry.isFullTank ? Colors.green[700] : Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Amount
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${fuelEntry.fuelAmount.toStringAsFixed(1)}L',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    // Odometer
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${fuelEntry.currentKm.toStringAsFixed(0)} km',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error loading entries: $error'),
    );
  }

}

/// Helper function to show period detail modal
void showPeriodDetailModal(BuildContext context, EnhancedConsumptionDataPoint periodData) {
  showDialog(
    context: context,
    builder: (context) => PeriodDetailModal(periodData: periodData),
  );
}