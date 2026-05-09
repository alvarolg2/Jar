import 'package:flutter/material.dart';

class WeeklyMovementData {
  final List<int> weeklyIn;
  final List<int> weeklyOut;
  final List<String> weekLabels;
  final int totalIn;
  final int totalOut;
  final int netBalance;

  WeeklyMovementData({
    required this.weeklyIn,
    required this.weeklyOut,
    required this.weekLabels,
    required this.totalIn,
    required this.totalOut,
    required this.netBalance,
  });

  factory WeeklyMovementData.fromRawData(List<Map<String, dynamic>> data,
      {int weeks = 5, String Function(int)? getMonthLabel}) {
    final inData = <String, int>{};
    final outData = <String, int>{};
    final sortedDates = <String>{};

    for (var item in data) {
      final date = item['date'] as String;
      final type = item['type'] as String;
      final count = item['count'] as int;
      sortedDates.add(date);
      if (type == 'in') {
        inData[date] = count;
      } else {
        outData[date] = count;
      }
    }

    final sortedDateList = sortedDates.toList()..sort();
    final totalIn = inData.values.fold(0, (a, b) => a + b);
    final totalOut = outData.values.fold(0, (a, b) => a + b);
    final netBalance = totalIn - totalOut;

    final now = DateTime.now();
    final weeklyIn = <int>[];
    final weeklyOut = <int>[];
    final weekLabels = <String>[];

    for (int w = weeks - 1; w >= 0; w--) {
      final weekEnd = now.subtract(Duration(days: w * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 6));
      final startStr = weekStart.toIso8601String().split('T').first;
      final endStr = weekEnd.toIso8601String().split('T').first;

      int sumIn = 0, sumOut = 0;
      for (final date in sortedDateList) {
        if (date.compareTo(startStr) >= 0 && date.compareTo(endStr) <= 0) {
          sumIn += inData[date] ?? 0;
          sumOut += outData[date] ?? 0;
        }
      }
      weeklyIn.add(sumIn);
      weeklyOut.add(sumOut);

      final startDay = weekStart.day.toString().padLeft(2, '0');
      final endDay = weekEnd.day.toString().padLeft(2, '0');
      final month = getMonthLabel != null
          ? getMonthLabel(weekEnd.month)
          : _defaultMonthLabel(weekEnd.month);
      weekLabels.add('$startDay-$endDay $month');
    }

    return WeeklyMovementData(
      weeklyIn: weeklyIn,
      weeklyOut: weeklyOut,
      weekLabels: weekLabels,
      totalIn: totalIn,
      totalOut: totalOut,
      netBalance: netBalance,
    );
  }

  static String _defaultMonthLabel(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  int get maxWeekly => [
        ...weeklyIn,
        ...weeklyOut
      ].reduce((a, b) => a > b ? a : b);
}
