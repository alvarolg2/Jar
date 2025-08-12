import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jar/ui/common/app_colors.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/common/app_strings.dart';
import 'package:jar/ui/common/ui_helpers.dart';
import 'package:jar/ui/views/create_received/create_received_viewmodel.dart';
import 'package:stacked/stacked.dart';

class CreateReceivedView extends StatelessWidget {
  final Warehouse warehouse;

  const CreateReceivedView({Key? key, required this.warehouse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateReceivedViewModel>.reactive(
      viewModelBuilder: () => CreateReceivedViewModel(),
      onViewModelReady: (viewModel) => viewModel.init(warehouse),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text(addReception, style: TextStyle(color: kcTextColor)),
          backgroundColor: kcPrimaryColor,
        ),
        backgroundColor: kcBackgroundColor,
        body: Form(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              TextFormField(
                controller: viewModel.productController,
                decoration: const InputDecoration(
                  labelText: product,
                  labelStyle: TextStyle(color: kcPrimaryColorDark),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kcPrimaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kcPrimaryColorDark),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return validateProduct;
                  }
                  return null;
                },
              ),
              verticalSpaceMedium,
              TextFormField(
                controller: viewModel.lotController,
                decoration: const InputDecoration(
                  labelText: batch,
                  labelStyle: TextStyle(color: kcPrimaryColorDark),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kcPrimaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kcPrimaryColorDark),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
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
                  labelText: numberOfPallets,
                  labelStyle: TextStyle(color: kcPrimaryColorDark),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kcPrimaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kcPrimaryColorDark),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return validatePallets;
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
                    onPressed: viewModel.captureAndRecognizeText,
                    icon: const Icon(Icons.camera_alt, color: kcPrimaryColorDark),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              viewModel.isBusy
                  ? const CircularProgressIndicator(color: kcPrimaryColor)
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: kcPrimaryColor, // foreground (text) color
                      ),
                      onPressed: () async {
                        await viewModel.createLot(warehouse);
                        viewModel.navigateToHome();
                      },
                      icon: const Icon(Icons.save),
                      label: const Text(save),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
