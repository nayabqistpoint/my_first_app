import 'package:flutter/foundation.dart';

class SaleController extends ChangeNotifier {
  final List<Map<String, dynamic>> _itemList = [];
  List<Map<String, dynamic>> get itemList => _itemList;

  double _discountValue = 0.0;
  bool _isPercentageDiscount = false;

  double get subTotal {
    double total = 0.0;
    for (var item in _itemList) {
      final qty = item['qty'] as int? ?? 1;
      final price = (item['salePrice'] as num?)?.toDouble() ?? 0.0;
      total += qty * price;
    }
    return total;
  }

  double get discountAmount {
    if (_isPercentageDiscount) {
      return (subTotal * _discountValue) / 100;
    } else {
      return _discountValue;
    }
  }

  double get grandTotal {
    double total = subTotal - discountAmount;
    return total < 0 ? 0 : total;
  }

  void setDiscount(double value, bool isPercentage) {
    _discountValue = value;
    _isPercentageDiscount = isPercentage;
    notifyListeners();
  }

  void saveItem({
    int? editIndex,
    required String model,
    required int qty,
    required double purchasePrice,
    required double salePrice,
    required String desc,
    required String imei,
    required String category,
    required String supplier,
    required String color,
  }) {
    final newItem = {
      'model': model,
      'qty': qty,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'desc': desc,
      'imei': imei,
      'category': category,
      'supplier': supplier,
      'color': color,
    };

    if (editIndex != null && editIndex >= 0 && editIndex < _itemList.length) {
      _itemList[editIndex] = newItem;
    } else {
      _itemList.add(newItem);
    }
    notifyListeners();
  }

  void deleteItem(int index) {
    if (index >= 0 && index < _itemList.length) {
      _itemList.removeAt(index);
      notifyListeners();
    }
  }

  void clearSale() {
    _itemList.clear();
    _discountValue = 0.0;
    _isPercentageDiscount = false;
    notifyListeners();
  }
}

final SaleController saleController = SaleController();