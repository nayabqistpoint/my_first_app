import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StockItem {
  String name;
  String imei;
  int quantity;
  double purchasePrice;
  double salePrice;
  String supplierName;
  String category;
  String color;

  StockItem({
    required this.name,
    required this.imei,
    required this.quantity,
    required this.purchasePrice,
    required this.salePrice,
    required this.supplierName,
    required this.category,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'imei': imei,
        'quantity': quantity,
        'purchasePrice': purchasePrice,
        'salePrice': salePrice,
        'supplierName': supplierName,
        'category': category,
        'color': color,
      };

  factory StockItem.fromJson(Map<dynamic, dynamic> json) {
    return StockItem(
      name: json['name'] ?? '',
      imei: json['imei'] ?? '',
      quantity: json['quantity'] ?? 0,
      purchasePrice: (json['purchasePrice'] ?? 0).toDouble(),
      salePrice: (json['salePrice'] ?? 0).toDouble(),
      supplierName: json['supplierName'] ?? 'نامعلوم سپلائر',
      category: json['category'] ?? 'موبائل فون',
      color: json['color'] ?? 'کوئی رنگ نہیں',
    );
  }
}

class ItemController extends ChangeNotifier {
  static const String _boxName = 'stockBox';

  Box get stockBox {
    if (!Hive.isBoxOpen(_boxName)) {
      throw HiveError('Box $_boxName is not open. Make sure to open it in main().');
    }
    return Hive.box(_boxName);
  }

  // صرف وہی آئٹمز دکھائیں جن کی کوانٹٹی صفر سے زیادہ ہو
  List<StockItem> get items {
    try {
      final rawData = stockBox.values.toList();
      return rawData
          .map((e) => StockItem.fromJson(e as Map<dynamic, dynamic>))
          .where((item) => item.quantity > 0)
          .toList();
    } catch (e) {
      return [];
    }
  }

  String searchQuery = "";
  String searchFilter = "بذریعہ نام";

  void addItem({
    required String name,
    required String imei,
    required int quantity,
    required double purchasePrice,
    required double salePrice,
    String supplierName = "نامعلوم سپلائر",
    String category = "موبائل فون",
    String color = "کوئی رنگ نہیں",
  }) {
    final cleanCategory = (category.trim().isEmpty || category.contains('हिंदी') || category.contains('ह')) 
        ? 'موبائل فون' 
        : category;

    final cleanColor = (color.trim().isEmpty || color.contains('हिंदी') || color.contains('ह')) 
        ? 'کوئی رنگ نہیں' 
        : color;
        
    final cleanSupplier = (supplierName.trim().isEmpty) ? 'نامعلوم سپلائر' : supplierName;

    int existingKey = -1;

    for (var key in stockBox.keys) {
      final rawData = stockBox.get(key);
      if (rawData != null && rawData is Map) {
        String existingName = rawData['name'] ?? '';
        String existingImei = rawData['imei'] ?? '';

        if (existingName.trim().toLowerCase() == name.trim().toLowerCase() &&
            existingImei.trim().toLowerCase() == imei.trim().toLowerCase()) {
          existingKey = key;
          break;
        }
      }
    }

    if (existingKey != -1) {
      final existingData = stockBox.get(existingKey) as Map;
      int oldQty = existingData['quantity'] ?? 0;

      StockItem updatedItem = StockItem(
        name: name,
        imei: imei,
        quantity: oldQty + quantity,
        purchasePrice: purchasePrice,
        salePrice: salePrice,
        supplierName: cleanSupplier != "نامعلوم سپلائر" ? cleanSupplier : (existingData['supplierName'] ?? 'نامعلوم سپلائر'),
        category: cleanCategory != "موبائل فون" ? cleanCategory : (existingData['category'] ?? 'موبائل فون'),
        color: cleanColor != "کوئی رنگ نہیں" ? cleanColor : (existingData['color'] ?? 'کوئی رنگ نہیں'),
      );

      stockBox.put(existingKey, updatedItem.toJson());
    } else {
      StockItem newItem = StockItem(
        name: name,
        imei: imei,
        quantity: quantity,
        purchasePrice: purchasePrice,
        salePrice: salePrice,
        supplierName: cleanSupplier,
        category: cleanCategory,
        color: cleanColor,
      );
      stockBox.add(newItem.toJson());
    }

    notifyListeners();
  }

  void removeItem(int index) {
    stockBox.deleteAt(index);
    notifyListeners();
  }

  void reduceItemStock({
    required String name,
    required String imei,
    required int quantityToSubtract,
  }) {
    int remainingToSubtract = quantityToSubtract;

    for (var key in stockBox.keys) {
      final rawData = stockBox.get(key);
      if (rawData != null && rawData is Map) {
        StockItem item = StockItem.fromJson(rawData);
        
        bool isMatch = false;
        if (imei.trim().isNotEmpty && item.imei.trim().toLowerCase() == imei.trim().toLowerCase()) {
          isMatch = true;
        } else if (item.name.trim().toLowerCase() == name.trim().toLowerCase()) {
          isMatch = true;
        }

        if (isMatch && item.quantity > 0) {
          if (item.quantity >= remainingToSubtract) {
            item.quantity -= remainingToSubtract;
            remainingToSubtract = 0;
          } else {
            remainingToSubtract -= item.quantity;
            item.quantity = 0;
          }
          stockBox.put(key, item.toJson());
          if (remainingToSubtract <= 0) break;
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
    // items پہلے ہی quantity > 0 والے دے رہا ہے، لہذا یہیں سے فلٹر ہو گا
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

final ItemController itemController = ItemController();