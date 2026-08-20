import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StockItem {
  final String name;
  final String imei;
  final double purchasePrice;
  final int quantity;
  final String status;

  StockItem({
    required this.name,
    required this.imei,
    required this.purchasePrice,
    required this.quantity,
    required this.status,
  });

  // Hive Box کے ڈیٹا کو محفوظ طریقے سے پارس کرنے کی لاجک
  factory StockItem.fromJson(Map<dynamic, dynamic> json) {
    // String یا double دونوں صورتوں کو ہینڈل کرنا
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    // String یا int دونوں صورتوں کو ہینڈل کرنا
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return StockItem(
      name: (json['itemName'] ?? json['name'] ?? '').toString(),
      imei: (json['imeiNo'] ?? json['imei'] ?? '').toString(),
      purchasePrice: parseDouble(json['purchasePrice']),
      quantity: parseInt(json['quantity']),
      status: (json['status'] ?? 'available').toString(),
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

  // UI اور پچھلی ڈیپینڈینسی کے لیے items اور filteredItems دونوں موجود ہیں
  List<StockItem> get items {
    try {
      final rawData = stockBox.values.toList();

      return rawData
          .whereType<Map>() // صرف وہی ریکارڈز جو Map شکل میں ہیں
          .map((e) => StockItem.fromJson(e))
          .where((item) {
            final bool hasQty = item.quantity > 0;
            final String st = item.status.toLowerCase().trim();
            final bool isActive = st == 'available' || st == 'active' || st == 'in' || st.isEmpty;
            
            return hasQty && isActive;
          })
          .toList();
    } catch (e) {
      debugPrint("Stock Error: $e");
      return [];
    }
  }

  List<StockItem> get filteredItems => items;
}

final ItemController itemController = ItemController();