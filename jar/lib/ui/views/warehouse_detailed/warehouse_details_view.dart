import 'package:flutter/material.dart';
import 'package:jar/helpers/database_helper.dart';
import 'package:jar/models/warehouse.dart';

class WarehouseDetailsView extends StatelessWidget {
  final Warehouse warehouse;

  WarehouseDetailsView({required this.warehouse});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Warehouse Name: ${warehouse.name}'),
        ElevatedButton(
          onPressed: () => _showEditNameDialog(context),
          child: Text('Edit Name'),
        ),
        // Otros detalles del almacén aquí...
      ],
    );
  }

  void _showEditNameDialog(BuildContext context) {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Warehouse Name'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Enter new warehouse name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_controller.text.isNotEmpty) {
                  await DatabaseHelper.instance
                      .updateWarehouseName(warehouse.id!, _controller.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
