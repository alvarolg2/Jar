import 'package:flutter/material.dart';
import 'package:jar/l10n/app_localizations.dart';
import 'package:jar/ui/views/analysis/analysis_viewmodel.dart';
import 'package:jar/ui/views/analysis/widgets/stat_card.dart';
import 'package:jar/ui/views/analysis/widgets/trend_chart.dart';
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
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 12,
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
                      Expanded(
                        child: StatCard(
                          title: l10n.dispatched,
                          value: '${viewModel.globalStats['totalOut'] ?? 0}',
                          icon: Icons.local_shipping,
                          color: Colors.green.shade700,
                        ),
                      ),
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
                  // 2. Warehouse Distribution
                  Text(
                    l10n.warehouseDistribution,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: viewModel.warehouseDistribution.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = viewModel.warehouseDistribution[index];
                        return ListTile(
                          leading: const Icon(Icons.warehouse),
                          title: Text(item['warehouseName'] ?? l10n.unknown),
                          trailing: Text(
                            l10n.palletsCountLabel(item['count'] ?? 0),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  // 3. Movement Trends
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

                  // 4. Top Products
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
                          case 0: // Gold
                            avatarBgColor = const Color(0xFFFFD700);
                            avatarFgColor = Colors.black;
                            break;
                          case 1: // Silver
                            avatarBgColor = const Color(0xFFC0C0C0);
                            avatarFgColor = Colors.black;
                            break;
                          case 2: // Bronze
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
    );
  }

  @override
  AnalysisViewModel viewModelBuilder(BuildContext context) =>
      AnalysisViewModel();

  @override
  void onViewModelReady(AnalysisViewModel viewModel) => viewModel.initialise();
}
