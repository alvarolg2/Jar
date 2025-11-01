import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jar/l10n/app_localizations.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/ui/common/app_colors.dart';
import 'package:jar/ui/common/ui_helpers.dart';
import 'package:jar/ui/views/create_received/create_received_viewmodel.dart';
import 'package:stacked/stacked.dart';

class CreateReceivedView extends StatefulWidget {
  final Warehouse warehouse;

  const CreateReceivedView({Key? key, required this.warehouse})
      : super(key: key);

  @override
  State<CreateReceivedView> createState() => _CreateReceivedViewState();
}

class _CreateReceivedViewState extends State<CreateReceivedView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ViewModelBuilder<CreateReceivedViewModel>.reactive(
      viewModelBuilder: () => CreateReceivedViewModel(),
      onViewModelReady: (viewModel) => viewModel.init(widget.warehouse),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.addReception),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: <Widget>[
              TextFormField(
                controller: viewModel.productNameController,
                decoration:  InputDecoration(
                  labelText: l10n.productName,
                  helperText: l10n.requiredField,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validateProduct;
                  }
                  return null;
                },
              ),
              verticalSpaceMedium,
              TextFormField(
                controller: viewModel.productDescriptionController,
                decoration: InputDecoration(
                  labelText: l10n.productDescription,
                ),
              ),
              verticalSpaceMedium,
              TextFormField(
                controller: viewModel.lotController,
                decoration: InputDecoration(
                  labelText: l10n.batch,
                  helperText: l10n.requiredField,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validateBatch;
                  }
                  return null;
                },
              ),
              verticalSpaceMedium,
              TextFormField(
                controller: viewModel.numPalletController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  labelText: l10n.numberOfPallets,
                  helperText: l10n.requiredField,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.validatePallets;
                  }
                  if ((int.tryParse(value) ?? 0) <= 0) {
                    return l10n.validatePalletsNumber;
                  }
                  return null;
                },
              ),
              verticalSpaceMedium,
              Card(
                color: kcSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                  )
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.secondary),
                  title: Text(
                    l10n.scanDocument,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: viewModel.isBusy ? null : viewModel.captureAndRecognizeText,
                  trailing: viewModel.isBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
              
              verticalSpaceLarge,
              
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: kcBrandAccent.withOpacity(0.5),
                ).copyWith(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return kcBrandAccent.withOpacity(0.5);
                      }
                      return kcBrandAccent;
                    },
                  ),
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
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  viewModel.isBusy ? l10n.saving : l10n.save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}