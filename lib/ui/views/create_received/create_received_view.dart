import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/common/app_colors.dart';
import 'package:jar/ui/common/app_strings.dart';
import 'package:jar/ui/common/ui_helpers.dart';
import 'package:jar/ui/views/create_received/create_received_viewmodel.dart';
import 'package:stacked/stacked.dart';

class CreateReceivedView extends StatefulWidget {
  final Warehouse warehouse;

  const CreateReceivedView({Key? key, required this.warehouse}) : super(key: key);

  @override
  State<CreateReceivedView> createState() => _CreateReceivedViewState();
}

class _CreateReceivedViewState extends State<CreateReceivedView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateReceivedViewModel>.reactive(
      viewModelBuilder: () => CreateReceivedViewModel(),
      onViewModelReady: (viewModel) => viewModel.init(widget.warehouse),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text(addReception, style: TextStyle(color: kcTextColor)),
          backgroundColor: kcPrimaryColor,
        ),
        backgroundColor: kcBackgroundColor,
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              TextFormField(
                controller: viewModel.productNameController,
                decoration: const InputDecoration(
                  labelText: "Nombre del producto",
                  helperText: '* Requerido', 
                  helperStyle: TextStyle(color: kcPrimaryColorDark, fontStyle: FontStyle.italic),
                  labelStyle: TextStyle(color: kcPrimaryColorDark),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: kcPrimaryColor)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kcPrimaryColorDark)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return validateProduct;
                  }
                  return null;
                },
              ),
              verticalSpaceMedium,
              TextFormField(
                controller: viewModel.productDescriptionController,
                decoration: const InputDecoration(
                  labelText: "Descripción del producto",
                  labelStyle: TextStyle(color: kcPrimaryColorDark),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: kcPrimaryColor)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kcPrimaryColorDark)),
                ),
              ),
              verticalSpaceMedium,
              TextFormField(
                controller: viewModel.lotController,
                decoration: const InputDecoration(
                  labelText: "Lote",
                  helperText: '* Requerido',
                  helperStyle: TextStyle(color: kcPrimaryColorDark, fontStyle: FontStyle.italic),
                  labelStyle: TextStyle(color: kcPrimaryColorDark),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: kcPrimaryColor)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kcPrimaryColorDark)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return validateBatch;
                  }
                  return null;
                },
              ),
              verticalSpaceMedium,
              TextFormField(
                controller: viewModel.numPalletController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "Número de palets",
                  helperText: '* Requerido',
                  helperStyle: TextStyle(color: kcPrimaryColorDark, fontStyle: FontStyle.italic),
                  labelStyle: TextStyle(color: kcPrimaryColorDark),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: kcPrimaryColor)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kcPrimaryColorDark)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return validatePallets;
                  }
                  if ((int.tryParse(value) ?? 0) <= 0) {
                    return 'El número debe ser mayor que cero';
                  }
                  return null;
                },
              ),
              verticalSpaceMedium,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    scanDocument,
                    style: TextStyle(fontSize: 16, color: kcTextColor),
                  ),
                  IconButton(
                    onPressed: viewModel.isBusy ? null : viewModel.captureAndRecognizeText,
                    icon: const Icon(Icons.camera_alt, color: kcPrimaryColorDark),
                    tooltip: "Escanear etiqueta",
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: kcPrimaryColor,
                  disabledBackgroundColor: kcPrimaryColor.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: viewModel.isBusy
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          bool success = await viewModel.createLot();
                          if (success && mounted) {
                            viewModel.navigateToHome();
                          }
                        }
                      },
                icon: viewModel.isBusy
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Icon(Icons.save),
                label: Text(viewModel.isBusy ? "Guardando..." : save, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}