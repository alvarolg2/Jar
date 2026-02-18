import 'package:flag/flag.dart'; // <-- 1. CORRECCIÓN DE IMPORTACIÓN
import 'package:flutter/material.dart';
import 'package:jar/l10n/app_localizations.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/common/app_colors.dart';
import 'package:jar/ui/common/ui_helpers.dart';
import 'package:jar/ui/views/warehouse_detailed/warehouse_details_view.dart';
import 'package:stacked/stacked.dart';
import 'package:jar/ui/common/app_locales.dart';

import 'home_viewmodel.dart';

enum _MenuOptions { import, export, generateReport, langEs, langEn, langFr }

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        if (model.warehouseCount > 0) {
          model.initTabController(this);
        }

        if (model.isBusy && model.warehouses.isEmpty) {
          return Scaffold(
            body: Center(
              child:
                  CircularProgressIndicator(color: theme.colorScheme.secondary),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.myWarehouses,
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            actions: [
              Padding(
                padding:
                    const EdgeInsets.only(right: 8.0, top: 4.0, bottom: 4.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          model.isActivated
                              ? Icons.warning
                              : Icons.warning_amber_outlined,
                          color: model.isActivated
                              ? kcDefectiveColor
                              : Colors.white,
                        ),
                        onPressed: model.warehouses.isNotEmpty
                            ? model.toggleActivation
                            : null,
                        tooltip: l10n.tooltipDefectiveButton,
                      ),
                      PopupMenuButton<_MenuOptions>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        tooltip: l10n.moreOptions,
                        onSelected: (value) {
                          if (value == _MenuOptions.import)
                            model.importDatabase();
                          else if (value == _MenuOptions.export)
                            model.exportDatabase();
                          else if (value == _MenuOptions.generateReport)
                            model.generateAndShareWarehouseReport();
                          else if (value == _MenuOptions.langEs)
                            model.setLocale(const Locale('es'));
                          else if (value == _MenuOptions.langEn)
                            model.setLocale(const Locale('en'));
                          else if (value == _MenuOptions.langFr)
                            model.setLocale(const Locale('fr'));
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<_MenuOptions>>[
                          PopupMenuItem(
                              value: _MenuOptions.import,
                              child: ListTile(
                                  leading:
                                      const Icon(Icons.download_for_offline),
                                  title: Text(l10n.importDB))),
                          PopupMenuItem(
                              value: _MenuOptions.export,
                              child: ListTile(
                                  leading: const Icon(Icons.upload_file),
                                  title: Text(l10n.exportDB))),
                          PopupMenuItem(
                              value: _MenuOptions.generateReport,
                              child: ListTile(
                                  leading: const Icon(Icons.picture_as_pdf),
                                  title: Text(l10n.generatePDFReport))),
                          const PopupMenuDivider(),
                          if (model.appVersion != null)
                            PopupMenuItem(
                              enabled: false,
                              child: Center(
                                child: Text(
                                  "${l10n.version} ${model.appVersion!.split(' ').last}",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Row(
                children: [
                  Expanded(
                    child: model.warehouseCount > 0
                        ? TabBar(
                            controller: model.tabController,
                            tabAlignment: TabAlignment.start,
                            isScrollable: true,
                            dividerColor: Colors.transparent,
                            indicator: const BoxDecoration(),
                            padding: const EdgeInsets.only(left: 12),
                            tabs: model.warehouses.map((warehouse) {
                              final index = model.warehouses.indexOf(warehouse);
                              return _BuildCustomTab(
                                warehouse: warehouse,
                                model: model,
                                onTap: () => model.setCurrentIndex(index),
                                onLongPress: () => _showWarehouseOptions(
                                    context, model,
                                    warehouse: warehouse),
                              );
                            }).toList(),
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (!model.isActivated) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconButton(
                        icon: const Icon(Icons.add_box_outlined,
                            color: Colors.white),
                        onPressed: () => _showWarehouseOptions(context, model),
                        tooltip: l10n.tooltipAddWarehouseButton,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Icon(
                          model.filterActive() == Colors.white
                              ? Icons.filter_list_off_outlined
                              : Icons.filter_list_alt,
                          color: model.filterActive(),
                        ),
                        onPressed: () =>
                            model.setShowDropdown(!model.showDropdown),
                        tooltip: l10n.filterByProduct,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            elevation: 4,
          ),
          body: model.warehouseCount > 0
              ? TabBarView(
                  controller: model.tabController,
                  children: model.warehouses.map((w) {
                    return WarehouseDetailsView(
                      warehouse: w,
                      defective: model.isActivated,
                    );
                  }).toList(),
                )
              : Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 32.0),
                    margin: const EdgeInsets.symmetric(horizontal: 24.0),
                    decoration: BoxDecoration(
                      color: kcSurface,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warehouse_rounded,
                          size: 50,
                          color: theme.colorScheme.secondary,
                        ),
                        verticalSpaceMedium,
                        Text(
                          l10n.noWarehouses,
                          style: theme.textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        verticalSpaceSmall,
                        Text(
                          l10n.noWarehousesMessage,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
          floatingActionButton:
              (model.isActivated != true && model.warehouses.isNotEmpty)
                  ? FloatingActionButton.extended(
                      onPressed: () => model.navigateToCreateReceived(context),
                      tooltip: l10n.addReception,
                      icon: const Icon(Icons.add),
                      label: Text(
                        l10n.addReception,
                      ),
                    )
                  : null,
        );
      },
    );
  }

  Widget _buildLanguageMenuItem(
      BuildContext context, HomeViewModel model, String langCode) {
    final theme = Theme.of(context);
    final isSelected = langCode == model.currentLocale.languageCode;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(3.0),
        child: Flag.fromString(
          kCountryCodes[langCode]!,
          height: 20,
          width: 28,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(kLocaleNames[langCode]!),
      trailing: isSelected
          ? Icon(Icons.check, color: theme.colorScheme.secondary)
          : null,
    );
  }
}

class _BuildCustomTab extends StatelessWidget {
  final Warehouse warehouse;
  final HomeViewModel model;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  const _BuildCustomTab({
    required this.warehouse,
    required this.model,
    this.onLongPress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = model.palletCounts[warehouse.id] ?? 0;
    final isSelected =
        model.currentIndex == model.warehouses.indexOf(warehouse);

    final Color selectedColor = theme.colorScheme.secondary;
    final Color defaultColor = theme.colorScheme.primary;

    return Tab(
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  warehouse.name ?? "",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? selectedColor : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              horizontalSpaceSmall,
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                constraints: const BoxConstraints(minWidth: 26),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected
                      ? (model.isActivated ? kcDefectiveColor : selectedColor)
                      : Colors.white.withOpacity(0.8),
                ),
                child: Center(
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : defaultColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showWarehouseOptions(BuildContext context, HomeViewModel model,
    {Warehouse? warehouse}) {
  final l10n = AppLocalizations.of(context)!;
  final TextEditingController controller =
      TextEditingController(text: warehouse?.name);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(warehouse == null ? l10n.addWarehouse : l10n.editWarehouse),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.nameWarehouse),
          autofocus: true,
        ),
        actions: <Widget>[
          TextButton(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          if (warehouse != null)
            TextButton(
              child: Text(l10n.delete,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onPressed: () {
                model.deleteWarehouse(warehouse);
                Navigator.of(context).pop();
              },
            ),
          TextButton(
            child: Text(warehouse == null ? l10n.add : l10n.save),
            onPressed: () {
              final name = controller.text;
              if (name.isNotEmpty) {
                if (warehouse == null) {
                  model.addWarehouse(name);
                } else {
                  model.updateWarehouseName(warehouse, name);
                }
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
