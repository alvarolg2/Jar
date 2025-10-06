import 'package:jar/models/product.dart';
import 'package:stacked/stacked.dart';

class FilterService with ListenableServiceMixin {

  final ReactiveValue<bool> showDropdown = ReactiveValue<bool>(false);
  final ReactiveValue<bool> filtersApply = ReactiveValue<bool>(false);

  final ReactiveValue<Product?> selectedProduct = ReactiveValue<Product?>(null);

  setShowDropdown(bool value) {
    showDropdown.value = value;
    notifyListeners();
  }

  void setSelectedProduct(Product? product) {
    selectedProduct.value = product;
    filtersApply.value = product != null;
    notifyListeners();
  }
}
