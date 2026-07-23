import 'package:flutter/material.dart';

class SalePurchaseController extends ChangeNotifier {
  int _selectedMode = 0;
  int get selectedMode => _selectedMode;

  void setMode(int mode) {
    if (_selectedMode != mode) {
      _selectedMode = mode;
      notifyListeners();
    }
  }

  final List<Map<String, dynamic>> _itemList = [];
  List<Map<String, dynamic>> get itemList => _itemList;

  double _discountValue = 0.0;
  bool _isDiscountPercentage = false;
  double get discountValue => _discountValue;
  bool get isDiscountPercentage => _isDiscountPercentage;

  void setDiscount(double value, bool isPercentage) {
    _discountValue = value;
    _isDiscountPercentage = isPercentage;
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
  }) {
    final newItemData = {
      'model': model,
      'qty': qty,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'desc': desc,
      'imei': imei,
      'category': category,
    };

    if (editIndex != null) {
      _itemList[editIndex] = newItemData;
    } else {
      _itemList.add(newItemData);
    }
    notifyListeners();
  }

  void deleteItem(int index) {
    _itemList.removeAt(index);
    notifyListeners();
  }

  double get subTotal {
    double total = 0.0;
    for (var item in _itemList) {
      final qty = item['qty'] as int;
      final price = _selectedMode == 0 
          ? (item['purchasePrice'] as double) 
          : (item['salePrice'] as double);
      total += (qty * price);
    }
    return total;
  }

  double get discountAmount {
    if (_isDiscountPercentage) {
      return (subTotal * _discountValue) / 100;
    } else {
      return _discountValue;
    }
  }

  double get grandTotal {
    return (subTotal - discountAmount).clamp(0.0, double.infinity);
  }
}

final SalePurchaseController salePurchaseController = SalePurchaseController();