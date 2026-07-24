import 'package:flutter/material.dart';

class StockItem {
  String name;
  String imei;
  int quantity;
  double purchasePrice;
  double salePrice;

  StockItem({
    required this.name,
    required this.imei,
    required this.quantity,
    required this.purchasePrice,
    required this.salePrice,
  });

  double get totalPurchaseValue => quantity * purchasePrice;
  double get totalSaleValue => quantity * salePrice;
}

class ItemController extends ChangeNotifier {
  final List<StockItem> items = [];

  String searchQuery = "";
  String searchFilter = "بذریعہ نام";

  void addItem({
    required String name,
    required String imei,
    required int quantity,
    required double purchasePrice,
    required double salePrice,
  }) {
    int existingIndex = items.indexWhere((item) =>
        item.name.trim().toLowerCase() == name.trim().toLowerCase() &&
        item.imei.trim().toLowerCase() == imei.trim().toLowerCase());

    if (existingIndex != -1) {
      items[existingIndex].quantity += quantity;
      items[existingIndex].purchasePrice = purchasePrice;
      items[existingIndex].salePrice = salePrice;
    } else {
      items.add(StockItem(
        name: name,
        imei: imei,
        quantity: quantity,
        purchasePrice: purchasePrice,
        salePrice: salePrice,
      ));
    }
    notifyListeners();
  }

  void removeItem(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  // --- سمارٹ اسٹاک کم کرنے والا فنکشن جو اب نہیں اٹکے گا ---
  void reduceItemStock({
    required String name,
    required String imei,
    required int quantityToSubtract,
  }) {
    int remainingToSubtract = quantityToSubtract;

    // مرحلہ 1: پہلے مخصوص IMEI والے آئٹم کو تلاش کر کے مائنس کریں
    if (imei.trim().isNotEmpty) {
      for (var item in items) {
        if (item.imei.trim().toLowerCase() == imei.trim().toLowerCase() &&
            item.name.trim().toLowerCase() == name.trim().toLowerCase()) {
          
          int available = item.quantity;
          if (available >= remainingToSubtract) {
            item.quantity -= remainingToSubtract;
            remainingToSubtract = 0;
          } else {
            remainingToSubtract -= available;
            item.quantity = 0;
          }
          break;
        }
      }
    }

    // مرحلہ 2: اگر مزید مقدار مائنس کرنی ہو تو نام کی بنیاد پر باری باری اگلی روز (Rows) سے مائنس کریں
    if (remainingToSubtract > 0) {
      for (var item in items) {
        if (item.name.trim().toLowerCase() == name.trim().toLowerCase()) {
          if (item.quantity > 0) {
            if (item.quantity >= remainingToSubtract) {
              item.quantity -= remainingToSubtract;
              remainingToSubtract = 0;
              break; 
            } else {
              remainingToSubtract -= item.quantity;
              item.quantity = 0; 
            }
          }
        }
      }
    }

    notifyListeners();
  }

  void updateSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void updateFilter(String filter) {
    searchFilter = filter;
    notifyListeners();
  }

  List<StockItem> get filteredItems {
    if (searchQuery.isEmpty) {
      return items;
    }
    return items.where((item) {
      if (searchFilter == 'بذریعہ IMEI') {
        return item.imei.toLowerCase().contains(searchQuery.toLowerCase());
      } else if (searchFilter == 'بذریعہ اسٹاک') {
        return item.quantity.toString().contains(searchQuery);
      } else {
        return item.name.toLowerCase().contains(searchQuery.toLowerCase());
      }
    }).toList();
  }
}

final itemController = ItemController();