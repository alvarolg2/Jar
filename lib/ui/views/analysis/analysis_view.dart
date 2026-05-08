import 'package:flutter/material.dart';
import 'package:jar/l10n/app_localizations.dart';
import 'package:jar/ui/views/analysis/analysis_viewmodel.dart';
import 'package:jar/ui/views/analysis/widgets/stat_card.dart';
import 'package:jar/ui/views/analysis/widgets/trend_chart.dart';
import 'package:jar/utils/date_formatter.dart';
import 'package:stacked/stacked.dart';

class AnalysisView extends StackedView<AnalysisViewModel> {
  const AnalysisView({super.key});

  @override
  Widget builder(
    BuildContext context,
    AnalysisViewModel viewModel,
    Widget? child,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analysisTitle),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => viewModel.generateAndShareAnalysisReport(),
            tooltip: l10n.generatePDFReport,
          ),
        ],
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => viewModel.initialise(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Global Stats
                    Text(
                      l10n.globalInventory,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: l10n.inStock,
                            value: '${viewModel.globalStats['totalIn'] ?? 0}',
                            icon: Icons.inventory_2,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            title: l10n.dispatched,
                            value: '${viewModel.globalStats['totalOut'] ?? 0}',
                            icon: Icons.local_shipping,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            title: l10n.defective,
                            value:
                                '${viewModel.globalStats['totalDefective'] ?? 0}',
                            icon: Icons.error_outline,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),

                    // 2. Secondary KPIs
                    Text(
                      l10n.keyPerformanceIndicators,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            label: l10n.defectRate,
                            value: '${viewModel.defectRate.toStringAsFixed(1)}%',
                            color: Colors.red.shade400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildKpiCard(
                            label: l10n.rotationRatio,
                            value: viewModel.rotationRatio.toStringAsFixed(2),
                            color: Colors.teal.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildKpiCard(
                            label: l10n.activeProducts,
                            value: '${viewModel.activeProducts}',
                            color: Colors.purple.shade600,
                          ),
                        ),
                      ],
                    ),

                    // 3. Warehouse Occupancy
                    Text(
                      l10n.warehouseOccupancy,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: viewModel.warehouseOccupancy.isEmpty
                            ? Center(child: Text(l10n.noData))
                            : Column(
                                children: viewModel.warehouseOccupancy
                                    .map((item) {
                                  final name =
                                      item['warehouseName'] ?? l10n.unknown;
                                  final percentage =
                                      (item['percentage'] as num?)
                                              ?.toDouble() ??
                                          0.0;
                                  final count =
                                      (item['count'] as num?)?.toInt() ?? 0;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            name,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: percentage / 100,
                                              minHeight: 10,
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.blue.shade700),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 50,
                                          child: Text(
                                            '${percentage.toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ),

                    // 4. Recent Activity
                    Text(
                      l10n.recentActivity,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Card(
                      child: viewModel.recentLotActivity.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(child: Text(l10n.noData)),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width - 32),
                                child: DataTable(
                                  columnSpacing: 12,
                                  horizontalMargin: 12,
                                  headingRowHeight: 36,
                                  dataRowMinHeight: 36,
                                  dataRowMaxHeight: 44,
                                  columns: [
                                    DataColumn(
                                        label: Text(l10n.date,
                                            style: const TextStyle(fontSize: 12))),
                                    DataColumn(
                                        label: Text(l10n.type,
                                            style: const TextStyle(fontSize: 12))),
                                    DataColumn(
                                        label: Text(l10n.product,
                                            style: const TextStyle(fontSize: 12))),
                                    DataColumn(
                                        label: Text(l10n.warehouse,
                                            style: const TextStyle(fontSize: 12))),
                                    DataColumn(
                                        label: Text(l10n.reportPalletCount,
                                            style: const TextStyle(fontSize: 12))),
                                  ],
                                  rows: viewModel.recentLotActivity.map((item) {
                                    final type =
                                        item['type']?.toString() ?? 'in';
                                    final isEntry = type == 'in';
                                    return DataRow(cells: [
                                      DataCell(Text(
                                        item['date'] != null
                                            ? formatDateLabel(
                                                item['date'].toString(), l10n)
                                            : l10n.noDate,
                                        style: const TextStyle(fontSize: 11),
                                      )),
                                      DataCell(Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isEntry
                                              ? Colors.green.shade100
                                              : Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isEntry
                                              ? l10n.movementIn
                                              : l10n.movementOut,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isEntry
                                                ? Colors.green.shade800
                                                : Colors.orange.shade800,
                                          ),
                                        ),
                                      )),
                                      DataCell(ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 120),
                                        child: Text(
                                          item['productName'] ?? l10n.unknown,
                                          style: const TextStyle(fontSize: 11),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )),
                                      DataCell(ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 100),
                                        child: Text(
                                          item['warehouseName'] ?? l10n.unknown,
                                          style: const TextStyle(fontSize: 11),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )),
                                      DataCell(Text(
                                        '${(item['palletCount'] as num?)?.toInt() ?? 0}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            ),
                    ),

                    // 5. Movement Trends
                    Text(
                      l10n.movementTrends30Days,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      l10n.movementLegend,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]),
                      child: TrendChart(data: viewModel.movementStats),
                    ),

                    // 6. Top Products
                    Text(
                      l10n.top5Products,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: viewModel.topProducts.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = viewModel.topProducts[index];

                          Color avatarBgColor;
                          Color avatarFgColor;

                          switch (index) {
                            case 0:
                              avatarBgColor = const Color(0xFFFFD700);
                              avatarFgColor = Colors.black;
                              break;
                            case 1:
                              avatarBgColor = const Color(0xFFC0C0C0);
                              avatarFgColor = Colors.black;
                              break;
                            case 2:
                              avatarBgColor = const Color(0xFFCD7F32);
                              avatarFgColor = Colors.white;
                              break;
                            default:
                              avatarBgColor = Colors.blue.shade100;
                              avatarFgColor = Colors.blue.shade900;
                          }

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: avatarBgColor,
                              foregroundColor: avatarFgColor,
                              child: Text('${index + 1}'),
                            ),
                            title: Text(item['productName'] ?? l10n.unknown),
                            subtitle: Text(
                              item['description'] ?? l10n.noDescription,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13),
                            ),
                            trailing: Text(
                              '${item['count']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  AnalysisViewModel viewModelBuilder(BuildContext context) =>
      AnalysisViewModel();

  @override
  void onViewModelReady(AnalysisViewModel viewModel) => viewModel.initialise();

  Widget _buildKpiCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
