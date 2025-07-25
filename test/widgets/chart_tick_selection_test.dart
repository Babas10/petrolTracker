import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Chart Tick Selection Algorithm Tests', () {
    
    test('getOptimalTickIndices returns all indices for small datasets', () {
      final indices = getOptimalTickIndices(4);
      expect(indices, equals([0, 1, 2, 3]));
    });

    test('getOptimalTickIndices includes first and last for large datasets', () {
      final indices = getOptimalTickIndices(20);
      expect(indices.first, equals(0));
      expect(indices.last, equals(19));
      expect(indices.length, lessThanOrEqualTo(6));
    });

    test('getOptimalTickIndices distributes ticks evenly', () {
      final indices = getOptimalTickIndices(10, maxTicks: 4);
      expect(indices, hasLength(4));
      expect(indices, contains(0));
      expect(indices, contains(9));
      
      // Check that intermediate ticks are reasonably distributed
      expect(indices, orderedEquals(indices.toList()..sort()));
    });

    test('shouldShowTick works correctly', () {
      // For a dataset of 10 items with max 4 ticks
      expect(shouldShowTick(0, 10), isTrue); // First always shown
      expect(shouldShowTick(9, 10), isTrue); // Last always shown
      
      // Some intermediate should be shown, some not
      final shownCount = List.generate(10, (i) => shouldShowTick(i, 10))
          .where((shown) => shown)
          .length;
      expect(shownCount, lessThanOrEqualTo(6)); // Default max ticks
    });

    test('getOptimalTickIndices handles edge cases', () {
      // Empty dataset
      expect(getOptimalTickIndices(0), isEmpty);
      
      // Single item
      expect(getOptimalTickIndices(1), equals([0]));
      
      // Two items
      expect(getOptimalTickIndices(2), equals([0, 1]));
    });

    test('maxTicks parameter is respected', () {
      final indices = getOptimalTickIndices(100, maxTicks: 3);
      expect(indices.length, lessThanOrEqualTo(3));
      expect(indices, contains(0));
      expect(indices, contains(99));
    });

    test('no duplicate indices are returned', () {
      final indices = getOptimalTickIndices(50);
      final uniqueIndices = indices.toSet();
      expect(indices.length, equals(uniqueIndices.length));
    });

    test('realistic fuel data scenarios', () {
      // Test with typical fuel entry data sizes
      
      // Small dataset (3 entries)
      final small = getOptimalTickIndices(3);
      expect(small, equals([0, 1, 2]));
      
      // Medium dataset (15 entries)
      final medium = getOptimalTickIndices(15);
      expect(medium.first, equals(0));
      expect(medium.last, equals(14));
      expect(medium.length, lessThanOrEqualTo(6));
      
      // Large dataset (50 entries)
      final large = getOptimalTickIndices(50);
      expect(large.first, equals(0));
      expect(large.last, equals(49));
      expect(large.length, lessThanOrEqualTo(6));
      
      // Very large dataset (200 entries)
      final veryLarge = getOptimalTickIndices(200);
      expect(veryLarge.first, equals(0));
      expect(veryLarge.last, equals(199));
      expect(veryLarge.length, lessThanOrEqualTo(6));
    });
  });
}

/// Smart tick selection algorithm for x-axis optimization
/// Returns list of indices that should show labels
List<int> getOptimalTickIndices(int dataLength, {int maxTicks = 6}) {
  if (dataLength <= maxTicks) {
    // If we have few data points, show all
    return List.generate(dataLength, (index) => index);
  }

  final ticks = <int>[];
  
  // Always include first and last
  ticks.add(0);
  if (dataLength > 1) {
    ticks.add(dataLength - 1);
  }

  // Calculate how many intermediate ticks we can fit
  final intermediateTicks = maxTicks - 2; // Subtract first and last
  
  if (intermediateTicks > 0) {
    // Distribute intermediate ticks evenly
    for (int i = 1; i <= intermediateTicks; i++) {
      final position = (dataLength - 1) * i / (intermediateTicks + 1);
      final index = position.round();
      
      // Avoid duplicates with first/last and ensure valid range
      if (index > 0 && index < dataLength - 1 && !ticks.contains(index)) {
        ticks.add(index);
      }
    }
  }

  // Sort to ensure proper order
  ticks.sort();
  return ticks;
}

/// Check if an index should show a label based on optimal tick selection
bool shouldShowTick(int index, int dataLength) {
  final optimalTicks = getOptimalTickIndices(dataLength);
  return optimalTicks.contains(index);
}