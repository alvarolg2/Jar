import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jar/helpers/database_helper.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/views/create_received/create_received_viewmodel.dart';
import 'package:stacked/stacked.dart';

class CreateReceivedView extends StatelessWidget {
  final Warehouse warehouse;

  const CreateReceivedView({Key? key, required this.warehouse})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateReceivedViewModel>.reactive(
      viewModelBuilder: () => CreateReceivedViewModel(),
      onModelReady: (viewModel) => viewModel.init(warehouse),
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
                controller: viewModel.lotController,
                decoration: InputDecoration(labelText: 'Lote'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un lote';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: viewModel.numPalletController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ], // Only numbers can be ent
                decoration: const InputDecoration(labelText: 'Número de pales'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un numero de pales';
                  }
                  return null;
                },
              ),
              IconButton(
                  onPressed: viewModel.captureAndRecognizeText,
                  icon: Icon(Icons.camera)),
              SizedBox(height: 20),
              viewModel.isBusy
                  ? CircularProgressIndicator() // Muestra un indicador de carga si el ViewModel está ocupado
                  : ElevatedButton(
                      onPressed: () async {
                        // Ahora, este botón llamará al método createReceived del ViewModel
                        await viewModel.createLot(warehouse);
                      },
                      child: Text('Guardar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
