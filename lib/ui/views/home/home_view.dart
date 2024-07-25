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
        }
        return Scaffold(
          appBar: AppBar(
            title: FutureBuilder<int>(
              future: model.isActivated ? model.getTotalPalletsNotOutDefectiveAll() : model.getTotalPalletsNotOutAll(),
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) { 
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // TODO: hacer banner para poner el numero por encima
                  return Image.asset('assets/images/background.png', scale: 6);
                } else {
                  return Container(
                    decoration:const  BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                              child: Text(
                                "${snapshot.data}",
                                style: const TextStyle(color: Colors.white),
                              ),           
                            ),
                          )
                        ),
                      ],
                    ),
                  );
                }
              }
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48.0),
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      labelColor: model.isActivated ? kcDefectiveShadeColor : null,
                      indicatorColor: model.isActivated ? kcDefectiveShadeColor : null,
                      controller: _tabController,
                      isScrollable: true,
                      tabs: List.generate(model.warehouses.length, (index) {
                        final warehouse = model.warehouses[index];
                        return _BuildCustomTab(
                          warehouse: warehouse,
                          onLongPress: () => _showWarehouseOptions(context, model, warehouse: warehouse),
                          onTap: () => _tabController!.animateTo(index),
                        );
                      }).toList(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.warning, 
                      color: model.isActivated ? kcDefectiveColor : Colors.grey
                    ),
                    onPressed: model.warehouses.isNotEmpty ? model.toggleActivation : null,
                    tooltip: tooltipDefectiveButton,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showWarehouseOptions(context, model),
                    tooltip: tooltipAddWarehouseButton,
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
  const _BuildCustomTab({this.warehouse, this.onLongPress, this.onTap});

  @override
  Widget builder(BuildContext context, HomeViewModel model) {
    return InkWell(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Tab(
        child: Row(
          children: [
            Text(warehouse?.name ?? ""),
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
                  child: 
                    FutureBuilder<int>(
                      future: model.isActivated ? model.getTotalPalletsNotOutDefective(warehouseId: warehouse!.id!) : model.getTotalPalletsNotOut(warehouseId: warehouse!.id!), 
                      builder: (BuildContext context, AsyncSnapshot<int> snapshot) { 
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text(
                            "0",
                            style: TextStyle(color: Colors.white) ,
                          );
                        }
                        return Text(
                          "${snapshot.data}",
                          style: const TextStyle(color: Colors.white),
                        );
                      },
                    )
                  ,
                ),
              )
            ),
          ],
        ),),
    );
  }
}
