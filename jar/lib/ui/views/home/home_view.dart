import 'package:flutter/material.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/views/warehouse_detailed/warehouse_details_view.dart';
import 'package:stacked/stacked.dart';
import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      builder: (context, model, child) => DefaultTabController(
        length: model.warehouses.length + 1, // Número de tabs
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Almacen'),
            bottom: PreferredSize(
              preferredSize:
                  const Size.fromHeight(48.0), // Altura estándar de un TabBar
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      isScrollable:
                          true, // Permite desplazamiento si hay muchos elementos
                      tabs: model.warehouses
                          .map((warehouse) => _buildCustomTab(
                                title: warehouse.name,
                                onLongPress: () => _showWarehouseOptions(
                                    context, model,
                                    warehouse: warehouse),
                              ))
                          .toList()
                        ..add(
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () =>
                                _showWarehouseOptions(context, model),
                          ),
                        ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: model.isBusy
              ? const CircularProgressIndicator()
              : model.selectedWarehouse == null
                  ? const Center(child: Text('Selecciona un almacen'))
                  : WarehouseDetailsView(warehouse: model.selectedWarehouse!),
        ),
      ),
    );
  }
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

Widget _buildCustomTab(
    {required String title, required VoidCallback onLongPress}) {
  return InkWell(
    onLongPress: onLongPress,
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
                model.updateWarehouseName(warehouse.id!, name);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
