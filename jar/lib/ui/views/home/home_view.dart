import 'package:flutter/material.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/views/warehouse_detailed/warehouse_details_view.dart';
import 'package:stacked/stacked.dart';
import 'home_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
        viewModelBuilder: () => HomeViewModel(),
        onModelReady: (model) {
          _tabController =
              TabController(length: model.warehouseCount, vsync: this);
        },
        builder: (context, model, child) {
          // Verificar si es necesario actualizar el TabController
          if (_tabController!.length != model.warehouseCount) {
            _tabController!.dispose();
            _tabController =
                TabController(length: model.warehouseCount, vsync: this);
          }

          return Scaffold(
            appBar: AppBar(
              title: PreferredSize(
                preferredSize: const Size.fromHeight(48.0),
                child: Row(
                  children: [
                    Row(
                      children: [
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabs: List.generate(model.warehouses.length, (index) {
                            final warehouse = model.warehouses[index];
                            return _buildCustomTab(
                              title: warehouse.name ?? "Without name",
                              onLongPress: () => _showWarehouseOptions(
                                  context, model,
                                  warehouse: warehouse),
                              onTap: () => _tabController!.animateTo(
                                  index), // Esto debería funcionar correctamente
                            );
                          }).toList(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () =>
                              _showWarehouseOptions(context, model),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            body: TabBarView(
                controller: _tabController,
                children: model.warehouses
                    .map((warehouse) =>
                        WarehouseDetailsView(warehouse: warehouse))
                    .toList()),
            floatingActionButton: FloatingActionButton(
              onPressed: () => model.navigateToCreateReceived(
                  context, _tabController!.index),
              child: Icon(Icons.add),
            ),
          );
        });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _createNewWarehouse(BuildContext context, HomeViewModel model) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir un nuevo almacen'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Nombre del almacen"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Añadir'),
              onPressed: () {
                model.addWarehouse(controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomTab({
    required String title,
    required VoidCallback onLongPress,
    required VoidCallback
        onTap, // Este parámetro tampoco es necesario si ya manejas el tabController fuera
  }) {
    return InkWell(
      onLongPress: onLongPress,
      onTap: onTap, // Aquí es donde necesitas invocar el callback directamente
      child: Tab(text: title),
    );
  }

  void _showWarehouseOptions(BuildContext context, HomeViewModel model,
      {Warehouse? warehouse}) {
    final TextEditingController controller =
        TextEditingController(text: warehouse?.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(warehouse == null ? 'Añadir almacen' : 'Editar almacen'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Nombre almacen"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (warehouse != null)
              TextButton(
                child: const Text('Borrar'),
                onPressed: () {
                  model.deleteWarehouse(warehouse);
                  Navigator.of(context).pop();
                },
              ),
            TextButton(
              child: Text(warehouse == null ? 'Añadir' : 'Guardar'),
              onPressed: () {
                final name = controller.text;
                if (warehouse == null) {
                  model.addWarehouse(name);
                } else {
                  model.updateWarehouseName(warehouse, name);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
