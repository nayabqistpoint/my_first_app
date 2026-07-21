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
    items.add(StockItem(
      name: name,
      imei: imei,
      quantity: quantity,
      purchasePrice: purchasePrice,
      salePrice: salePrice,
    ));
    notifyListeners();
  }

  void removeItem(int index) {
    items.removeAt(index);
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