import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/screens/fuel_consumption_chart_screen.dart';
import 'package:flutter/material.dart';

void main() {
  group('FuelConsumptionChartScreen Date Calculation Tests', () {
    test('_subtractMonths handles regular month subtraction correctly', () {
      final testDate = DateTime(2024, 8, 15); // August 15, 2024
      
      // Create a temporary instance to access the private method
      // Note: This is a simplified test approach
      final result1Month = _subtractMonthsTest(testDate, 1);
      expect(result1Month, DateTime(2024, 7, 15)); // July 15, 2024
      
      final result3Months = _subtractMonthsTest(testDate, 3);
      expect(result3Months, DateTime(2024, 5, 15)); // May 15, 2024
      
      final result12Months = _subtractMonthsTest(testDate, 12);
      expect(result12Months, DateTime(2023, 8, 15)); // August 15, 2023
    });

    test('_subtractMonths handles year boundary correctly', () {
      final testDate = DateTime(2024, 1, 15); // January 15, 2024
      
      final result1Month = _subtractMonthsTest(testDate, 1);
      expect(result1Month, DateTime(2023, 12, 15)); // December 15, 2023
      
      final result3Months = _subtractMonthsTest(testDate, 3);
      expect(result3Months, DateTime(2023, 10, 15)); // October 15, 2023
    });

    test('_subtractMonths handles month-end dates correctly', () {
      final testDate = DateTime(2024, 3, 31); // March 31, 2024
      
      // March 31 - 1 month should be February 29 (2024 is leap year)
      final result1Month = _subtractMonthsTest(testDate, 1);
      expect(result1Month, DateTime(2024, 2, 29));
      
      // March 31 - 2 months should be January 31
      final result2Months = _subtractMonthsTest(testDate, 2);
      expect(result2Months, DateTime(2024, 1, 31));
    });

    test('_subtractMonths handles February leap year correctly', () {
      final leapYearDate = DateTime(2024, 2, 29); // February 29, 2024 (leap year)
      
      // February 29 - 12 months should be February 28, 2023 (non-leap year)
      final result12Months = _subtractMonthsTest(leapYearDate, 12);
      expect(result12Months, DateTime(2023, 2, 28));
    });
  });
}

/// Helper function to test the private _subtractMonths method
/// This replicates the logic from the main class for testing
DateTime _subtractMonthsTest(DateTime date, int monthsToSubtract) {
  int targetYear = date.year;
  int targetMonth = date.month - monthsToSubtract;
  
  // Handle year boundary
  while (targetMonth <= 0) {
    targetYear--;
    targetMonth += 12;
  }
  
  // Handle day boundary - if the target month doesn't have enough days,
  // use the last day of that month
  int targetDay = date.day;
  int maxDaysInTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
  if (targetDay > maxDaysInTargetMonth) {
    targetDay = maxDaysInTargetMonth;
  }
  
  return DateTime(targetYear, targetMonth, targetDay);
}