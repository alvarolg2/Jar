import 'package:flutter/material.dart';
import 'package:jar/l10n/app_localizations.dart';

class BarTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const BarTrendChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Center(child: Text(l10n.noData));
    }

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

    for (int w = 4; w >= 0; w--) {
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
      final month = _getMonthShort(weekEnd.month, context);
      weekLabels.add('$startDay-$endDay $month');
    }

    final maxWeekly = [...weeklyIn, ...weeklyOut].reduce((a, b) => a > b ? a : b);
    final chartHeight = 120.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              SizedBox(
                height: chartHeight + 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (int i = 0; i < weeklyIn.length; i++) ...[
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: 12,
                                  height: maxWeekly > 0
                                      ? (weeklyIn[i] / maxWeekly) * chartHeight
                                      : 0,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(2),
                                      topRight: Radius.circular(2),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 12,
                                  height: maxWeekly > 0
                                      ? (weeklyOut[i] / maxWeekly) * chartHeight
                                      : 0,
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(2),
                                      topRight: Radius.circular(2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              weekLabels[i],
                              style: const TextStyle(
                                  fontSize: 9, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      if (i < weeklyIn.length - 1) const SizedBox(width: 4),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 10, height: 8, color: Colors.green),
                  const SizedBox(width: 4),
                  Text('${AppLocalizations.of(context)!.movementIn} ($totalIn)',
                      style: const TextStyle(fontSize: 10)),
                  const SizedBox(width: 16),
                  Container(width: 10, height: 8, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('${AppLocalizations.of(context)!.movementOut} ($totalOut)',
                      style: const TextStyle(fontSize: 10)),
                  const SizedBox(width: 16),
                  Container(
                      width: 10,
                      height: 8,
                      color: netBalance >= 0 ? Colors.green : Colors.red),
                  const SizedBox(width: 4),
                  Text('Balance ($netBalance)',
                      style: const TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMonthShort(int month, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final months = [
      l10n.monthJan, l10n.monthFeb, l10n.monthMar, l10n.monthApr,
      l10n.monthMay, l10n.monthJun, l10n.monthJul, l10n.monthAug,
      l10n.monthSep, l10n.monthOct, l10n.monthNov, l10n.monthDec
    ];
    return months[month - 1];
  }
}
