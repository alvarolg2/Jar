import 'package:flutter/material.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/common/app_colors.dart';
import 'package:jar/ui/common/app_strings.dart';
import 'package:jar/ui/common/ui_helpers.dart';
import 'package:jar/ui/views/warehouse_detailed/warehouse_details_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'home_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onViewModelReady: (model) {
        _tabController = TabController(length: model.warehouseCount, vsync: this);
      },
      builder: (context, model, child) {
        if (_tabController!.length != model.warehouseCount) {
          _tabController!.dispose();
          _tabController = TabController(length: model.warehouseCount, vsync: this);
          _tabController!.addListener(() {
              if (!_tabController!.indexIsChanging) {
                model.notify();
          } });
        }
        return Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
                    decoration:const  BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  ),
            
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48.0),
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      tabAlignment: TabAlignment.start,
                      labelColor: model.isActivated ? kcDefectiveShadeColor : null,
                      indicatorColor: model.isActivated ? kcDefectiveShadeColor : null,
                      controller: _tabController,
                      isScrollable: true,
                      tabs: List.generate(model.warehouses.length, (index) {
                        final warehouse = model.warehouses[index];
                        return _BuildCustomTab(
                          defective: model.isActivated,
                          isSelected: _tabController!.index == index,
                          warehouse: warehouse,
                          onLongPress: () => _showWarehouseOptions(context, model, warehouse: warehouse),
                          onTap: () => _tabController!.animateTo(index),
                        );
                      }).toList(),
                    )
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.warning, 
                        color: model.isActivated ? kcDefectiveColor : Colors.white
                      ),
                      onPressed: model.warehouses.isNotEmpty ? model.toggleActivation : null,
                      tooltip: tooltipDefectiveButton,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => _showWarehouseOptions(context, model),
                      tooltip: tooltipAddWarehouseButton,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: model.warehouses.map((warehouse) => WarehouseDetailsView(warehouse: warehouse, defective: model.isActivated)).toList(),
          ),
          floatingActionButton: (model.isActivated != true && model.warehouses.isNotEmpty) 
            ? FloatingActionButton(
              onPressed: () => model.navigateToCreateReceived(context, _tabController!.index),
              tooltip: addReception,
              child: const Icon(Icons.add),
            ) 
            : null,
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _showWarehouseOptions(BuildContext context, HomeViewModel model, {Warehouse? warehouse}) {
    final TextEditingController controller = TextEditingController(text: warehouse?.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(warehouse == null ? addWarehouse : editWarehouse),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: nameWarehouse),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (warehouse != null)
              TextButton(
                child: const Text(delete),
                onPressed: () {
                  model.deleteWarehouse(warehouse);
                  Navigator.of(context).pop();
                },
              ),
            TextButton(
              child: Text(warehouse == null ? add : save),
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

class _BuildCustomTab extends StackedHookView<HomeViewModel> {
  final Warehouse? warehouse;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final bool defective;
  final bool isSelected;

  const _BuildCustomTab({this.warehouse, this.onLongPress, this.onTap, required this.isSelected, required this.defective});

  @override
  Widget builder(BuildContext context, HomeViewModel model) {
    return InkWell(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Tab(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.7) : Colors.black.withOpacity(0.5), // Fondo diferente para la pestaña seleccionada
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)), // Bordes redondeados para un aspecto moderno
            border: isSelected ? Border.all(color: Colors.blue, width: 2.0) : null, // Borde adicional para la pestaña seleccionada
          ),
          child: Row(
            children: [
              Text(
                warehouse?.name ?? "",
                style: TextStyle(color: isSelected ? Colors.white : Colors.white70), // Texto más destacado para la pestaña seleccionada
              ),
              horizontalSpaceTiny,
              Container(
                width: 30,
                height: 30,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: model.isActivated ? kcDefectiveColor : kcPrimaryColorDark,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: FittedBox(
                    child: FutureBuilder<int>(
                      future: model.isActivated
                          ? model.getTotalPalletsNotOutDefective(warehouseId: warehouse!.id!)
                          : model.getTotalPalletsNotOut(warehouseId: warehouse!.id!),
                      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text(
                            "0",
                            style: TextStyle(color: Colors.white),
                          );
                        }
                        return Text(
                          "${snapshot.data}",
                          style: const TextStyle(color: Colors.white),
                        );
                      },
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

