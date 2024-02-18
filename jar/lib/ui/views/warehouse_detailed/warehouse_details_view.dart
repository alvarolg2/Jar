import 'package:flutter/material.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/views/warehouse_detailed/warehouse_details_viewmodel.dart';
import 'package:stacked/stacked.dart';

class WarehouseDetailsView extends StatelessWidget {
  final Warehouse warehouse;

  const WarehouseDetailsView({Key? key, required this.warehouse})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WarehouseDetailsViewModel>.reactive(
      viewModelBuilder: () => WarehouseDetailsViewModel(warehouse),
      builder: (context, model, child) => model.isBusy
          ? const CircularProgressIndicator()
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // Ajusta según necesidad
              ),
              itemCount: model.data?.length ?? 0,
              itemBuilder: (context, index) {
                final received = model.data![index];
                return Card(
                  child: ListTile(
                    title: Column(
                      children: [
                        Text(received.id.toString()),
                        Text(received.date),
                        Text(received.warehouseId.toString()),
                      ],
                    ), // Asume que `Received` tiene un campo `date`
                    // Agrega más detalles según necesites
                  ),
                );
              },
            ),
    );
  }
}
