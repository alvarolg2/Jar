import 'package:flutter/material.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/common/app_colors.dart';
import 'package:jar/ui/common/ui_helpers.dart';
import 'package:jar/ui/views/warehouse_detailed/warehouse_details_view.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

enum _MenuOptions { import, export, generateReport }

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        if (model.warehouseCount > 0) {
          model.initTabController(this);
        }

        if (model.isBusy && model.warehouses.isEmpty) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: kcPrimaryColorDark),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 6.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.warning, color: model.isActivated ? kcDefectiveColor : Colors.white),
                        onPressed: model.warehouses.isNotEmpty ? model.toggleActivation : null,
                        tooltip: "Ver palets defectuosos",
                      ),
                      PopupMenuButton<_MenuOptions>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        tooltip: "Más opciones",
                        onSelected: (value) {
                          if (value == _MenuOptions.import) model.importDatabase();
                          else if (value == _MenuOptions.export) model.exportDatabase();
                          else if (value == _MenuOptions.generateReport) model.generateAndShareWarehouseReport();
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<_MenuOptions>>[
                          const PopupMenuItem(value: _MenuOptions.import, child: ListTile(leading: Icon(Icons.download_for_offline), title: Text('Importar BD'))),
                          const PopupMenuItem(value: _MenuOptions.export, child: ListTile(leading: Icon(Icons.upload_file), title: Text('Exportar BD'))),
                          const PopupMenuItem(value: _MenuOptions.generateReport, child: ListTile(leading: Icon(Icons.picture_as_pdf), title: Text('Generar Informe PDF'))),
                          const PopupMenuDivider(),
                          if (model.appVersion != null)
                            PopupMenuItem(
                              enabled: false, 
                              child: Center(
                                child: Text(
                                  model.appVersion!,
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
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
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
                            padding: const EdgeInsets.only(left: 8),
                            tabs: model.warehouses.map((warehouse) {
                              final index = model.warehouses.indexOf(warehouse);
                              return _BuildCustomTab(
                                warehouse: warehouse,
                                model: model,
                                onTap: () => model.setCurrentIndex(index),
                                onLongPress: () => _showWarehouseOptions(context, model, warehouse: warehouse),
                              );
                            }).toList(),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                       decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () => _showWarehouseOptions(context, model),
                        tooltip: "Añadir almacén",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: model.warehouseCount > 0
              ? TabBarView(
                  controller: model.tabController,
                  children: model.warehouses.map((w) {
                    return Column(
                      children: [
                        Expanded(
                          child: WarehouseDetailsView(warehouse: w, defective: model.isActivated),
                        ),
                      ],
                    );
                  }).toList(),
                )
              : Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warehouse_rounded,
            size: 50,
            color: Colors.white70,
          ),
          verticalSpaceMedium,
          Text(
            "No hay almacenes",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpaceSmall,
          Text(
            "Añade tu primer almacén usando el botón '+' de arriba.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  ),
          floatingActionButton: (model.isActivated != true && model.warehouses.isNotEmpty)
            ? FloatingActionButton.extended(
                onPressed: () => model.navigateToCreateReceived(context),
                tooltip: "Añadir recepción",
                backgroundColor: kcPrimaryColorDark, 
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text(
                  "Añadir Recepción",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                shape: const StadiumBorder(),
              )
            : null,
        );
      },
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
    final count = model.palletCounts[warehouse.id] ?? 0;
    final isSelected = model.currentIndex == model.warehouses.indexOf(warehouse);
    
    const selectedColor = Color(0xFF388E3C);

    return Tab(
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(25.0),
            border: isSelected ? Border.all(color: Colors.white, width: 1.5) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  warehouse.name ?? "",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              horizontalSpaceSmall,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                constraints: const BoxConstraints(
                  minWidth: 24,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected ? Colors.white : (model.isActivated ? kcDefectiveColor : kcPrimaryColorDark),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        color: isSelected ? selectedColor : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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

void _showWarehouseOptions(BuildContext context, HomeViewModel model, {Warehouse? warehouse}) {
  final TextEditingController controller = TextEditingController(text: warehouse?.name);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(warehouse == null ? "Añadir Almacén" : "Editar Almacén"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Nombre del almacén"),
          autofocus: true,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          if (warehouse != null)
            TextButton(
              child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
              onPressed: () {
                model.deleteWarehouse(warehouse);
                Navigator.of(context).pop();
              },
            ),
          TextButton(
            child: Text(warehouse == null ? "Añadir" : "Guardar"),
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