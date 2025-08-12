import 'package:flutter/material.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/common/app_colors.dart';
import 'package:jar/ui/common/app_strings.dart';
import 'package:jar/ui/common/ui_helpers.dart';
import 'package:jar/ui/views/warehouse_detailed/warehouse_details_view.dart';
import 'package:stacked/stacked.dart';
import 'home_viewmodel.dart';

enum _MenuOptions { import, export }

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
                            labelColor: model.isActivated ? kcDefectiveShadeColor : null,
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
                        : Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 16),
                            child: const Text("Añade un almacén", style: TextStyle(color: Colors.white)),
                          ),
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
                    child: IconButton(
                      icon: Icon(Icons.warning, color: model.isActivated ? kcDefectiveColor : Colors.white),
                      onPressed: model.warehouses.isNotEmpty ? model.toggleActivation : null,
                      tooltip: "Ver palets defectuosos",
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => _showWarehouseOptions(context, model),
                      tooltip: "Añadir almacén",
                    ),
                  ),
                  // ✅ REEMPLAZAMOS LOS BOTONES DIRECTOS POR UN MENÚ DESPLEGABLE
                  Container(
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
                    child: PopupMenuButton<_MenuOptions>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      tooltip: "Más opciones",
                      onSelected: (value) {
                        // Llama a la función correspondiente según la opción seleccionada.
                        if (value == _MenuOptions.import) {
                          model.importDatabase();
                        } else if (value == _MenuOptions.export) {
                          model.exportDatabase();
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<_MenuOptions>>[
                        const PopupMenuItem<_MenuOptions>(
                          value: _MenuOptions.import,
                          child: ListTile(
                            leading: Icon(Icons.download_for_offline),
                            title: Text('Importar BD'),
                          ),
                        ),
                        const PopupMenuItem<_MenuOptions>(
                          value: _MenuOptions.export,
                          child: ListTile(
                            leading: Icon(Icons.upload_file),
                            title: Text('Exportar BD'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: model.warehouseCount > 0
              ? TabBarView(
                  controller: model.tabController,
                  children: model.warehouses.map((warehouse) => WarehouseDetailsView(warehouse: warehouse, defective: model.isActivated)).toList(),
                )
              : const Center(child: Text("No hay almacenes", style: TextStyle(color: kcTextColor))),
          floatingActionButton: (model.isActivated != true && model.warehouses.isNotEmpty)
              ? FloatingActionButton(
                  onPressed: () => model.navigateToCreateReceived(context),
                  tooltip: "Añadir recepción",
                  child: const Icon(Icons.add),
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

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        margin: const EdgeInsets.only(top: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.9) : Colors.black.withOpacity(0.7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          border: isSelected ? Border.all(color: Colors.blue, width: 2.0) : null,
        ),
        child: Row(
          children: [
            Text(warehouse.name ?? "", style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
            horizontalSpaceTiny,
            Container(
              width: 30,
              height: 30,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: model.isActivated ? kcDefectiveColor : kcPrimaryColorDark,
              ),
              child: FittedBox(
                child: Text(
                  count.toString(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
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