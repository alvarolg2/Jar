import 'package:flutter/material.dart';
import 'package:jar/helpers/ui_helper.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/views/warehouse_detailed/warehouse_details_viewmodel.dart';
import 'package:stacked/stacked.dart';

class WarehouseDetailsView extends StatelessWidget {
  final Warehouse warehouse;

  const WarehouseDetailsView({Key? key, required this.warehouse})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(fontSize: 20);
    return ViewModelBuilder<WarehouseDetailsViewModel>.reactive(
      viewModelBuilder: () => WarehouseDetailsViewModel(warehouse),
      builder: (context, model, child) => model.isBusy
          ? const CircularProgressIndicator()
          : ListView.builder(
              itemCount: model.data?.length ?? 0,
              itemBuilder: (context, index) {
                final lots = model.data![index];
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined),
                              SizedBox(width: 8),
                              Text(
                                lots.name ?? "Without name",
                                style: style,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.ballot),
                              SizedBox(width: 8),
                              Text(
                                lots.product?.name ?? "Without product",
                                style: style,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.pallet),
                              SizedBox(width: 8),
                              Text(
                                  lots.pallet?.length.toString() ??
                                      "Without pallet",
                                  style: style),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.date_range),
                              SizedBox(width: 8),
                              Text(
                                DateFormatter.format(
                                    lots.createDate ?? DateTime.now()),
                                style: style,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
