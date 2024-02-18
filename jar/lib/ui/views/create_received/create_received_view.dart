import 'package:flutter/material.dart';
import 'package:jar/helpers/database_helper.dart';
import 'package:jar/models/user.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/views/create_received/create_received_viewmodel.dart';
import 'package:stacked/stacked.dart';

class CreateReceivedView extends StatelessWidget {
  final Warehouse warehouse;
  final User user;

  const CreateReceivedView(
      {Key? key, required this.warehouse, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateReceivedViewModel>.reactive(
      viewModelBuilder: () => CreateReceivedViewModel(),
      onModelReady: (viewModel) => viewModel.init(warehouse, user),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: Text('Añadir recepción'),
        ),
        body: Form(
          // Usa viewModel.formKey si decides mover _formKey al ViewModel
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              TextFormField(
                controller: viewModel.dateController,
                decoration: InputDecoration(labelText: 'Fecha'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una fecha';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: viewModel.productController,
                decoration: InputDecoration(labelText: 'Producto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un producto';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: viewModel.batchController,
                decoration: InputDecoration(labelText: 'Lote'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un lote';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              viewModel.isBusy
                  ? CircularProgressIndicator() // Muestra un indicador de carga si el ViewModel está ocupado
                  : ElevatedButton(
                      onPressed: () async {
                        // Ahora, este botón llamará al método createReceived del ViewModel
                        await viewModel.createReceived(warehouse, user);
                      },
                      child: Text('Guardar Received'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
