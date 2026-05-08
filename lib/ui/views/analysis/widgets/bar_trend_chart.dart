import 'package:flutter/material.dart';
import 'package:jar/l10n/app_localizations.dart';
import 'package:jar/utils/weekly_movement_data.dart';

class BarTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const BarTrendChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Center(child: Text(l10n.noData));
    }

    final l10n = AppLocalizations.of(context)!;
    final weekly = WeeklyMovementData.fromRawData(data,
        getMonthLabel: (month) {
          final months = [
            l10n.monthJan, l10n.monthFeb, l10n.monthMar, l10n.monthApr,
            l10n.monthMay, l10n.monthJun, l10n.monthJul, l10n.monthAug,
            l10n.monthSep, l10n.monthOct, l10n.monthNov, l10n.monthDec
          ];
          return months[month - 1];
        });

    final chartHeight = 110.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              SizedBox(
                height: chartHeight + 28,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (int i = 0; i < weekly.weeklyIn.length; i++) ...[
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 12,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (weekly.weeklyIn[i] > 0)
                                        Text(
                                          '${weekly.weeklyIn[i]}',
                                          style: const TextStyle(
                                              fontSize: 7, color: Colors.green),
                                        ),
                                      Container(
                                        height: weekly.maxWeekly > 0
                                            ? (weekly.weeklyIn[i] /
                                                    weekly.maxWeekly) *
                                                chartHeight
                                            : 0,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              const BorderRadius.only(
                                            topLeft: Radius.circular(2),
                                            topRight: Radius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 12,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (weekly.weeklyOut[i] > 0)
                                        Text(
                                          '${weekly.weeklyOut[i]}',
                                          style: const TextStyle(
                                              fontSize: 7,
                                              color: Colors.orange),
                                        ),
                                      Container(
                                        height: weekly.maxWeekly > 0
                                            ? (weekly.weeklyOut[i] /
                                                    weekly.maxWeekly) *
                                                chartHeight
                                            : 0,
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius:
                                              const BorderRadius.only(
                                            topLeft: Radius.circular(2),
                                            topRight: Radius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              weekly.weekLabels[i],
                              style: const TextStyle(
                                  fontSize: 9, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      if (i < weekly.weeklyIn.length - 1)
                        const SizedBox(width: 4),
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
                  Text('${l10n.movementIn} (${weekly.totalIn})',
                      style: const TextStyle(fontSize: 10)),
                  const SizedBox(width: 16),
                  Container(width: 10, height: 8, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('${l10n.movementOut} (${weekly.totalOut})',
                      style: const TextStyle(fontSize: 10)),
                  const SizedBox(width: 16),
                  Container(
                      width: 10,
                      height: 8,
                      color: weekly.netBalance >= 0
                          ? Colors.green
                          : Colors.red),
                  const SizedBox(width: 4),
                  Text('Balance (${weekly.netBalance})',
                      style: const TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
