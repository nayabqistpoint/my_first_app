import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LegalDocsController {
  bool isCnicReceived = false;
  bool isDocsSigned = false;
  bool isAdvanceReceived = false;
  bool isBoxReceived = false;
  bool isStampReceived = false;
  bool isChequesReceived = false;

  final TextEditingController remarksController = TextEditingController();
  String? handoverPhotoPath;

  bool get isReadyForHandover => isCnicReceived && isDocsSigned;

  Future<bool> completeHandover(String phone) async {
    final String cleanPhone = phone.trim();
    if (cleanPhone.isEmpty) return false;

    try {
      final Box packageBox = Hive.isBoxOpen('packageBox')
          ? Hive.box('packageBox')
          : await Hive.openBox('packageBox');

      dynamic targetKey;
      Map<String, dynamic>? targetData;

      // 1. کسٹمر کا پیکیج ڈائریکٹ فون نمبر سے تلاش کریں (بغیر ٹائم اسٹیمپ والی کیز کے)
      if (packageBox.containsKey(cleanPhone)) {
        targetKey = cleanPhone;
        var rawVal = packageBox.get(cleanPhone);
        if (rawVal is Map) targetData = Map<String, dynamic>.from(rawVal);
      } else {
        for (var key in packageBox.keys) {
          final val = packageBox.get(key);
          if (val is Map && (val['customerPhone'] ?? val['phone'] ?? '').toString().trim() == cleanPhone) {
            targetKey = key;
            targetData = Map<String, dynamic>.from(val);
            break;
          }
        }
      }

      // 2. اسی فون نمبر کی Key پر اسٹیٹس Completed کر دیں
      if (targetKey != null && targetData != null) {
        final String soldImei = (targetData['imei'] ?? '').toString().trim();
        final String soldMobileName = (targetData['mobileName'] ?? '').toString().trim();

        targetData['status'] = 'Completed';
        targetData['handoverTimestamp'] = DateTime.now().toIso8601String();
        targetData['handoverRemarks'] = remarksController.text.trim();
        targetData['handoverPhotoPath'] = handoverPhotoPath ?? '';

        targetData['securities'] = {
          'isCnicReceived': isCnicReceived,
          'isDocsSigned': isDocsSigned,
          'isAdvanceReceived': isAdvanceReceived,
          'isBoxReceived': isBoxReceived,
          'isStampReceived': isStampReceived,
          'isChequesReceived': isChequesReceived,
        };

        // 🎯 Key کو بدلے بغیر اسی فون نمبر کی key پر سیو کریں
        await packageBox.put(targetKey, targetData);

        // 🎯 Stock Box میں سے موبائل کو Sold کریں
        await _reduceStock(soldImei, soldMobileName);

        return true;
      }
    } catch (e) {
      debugPrint("Handover Error: $e");
    }
    return false;
  }

  Future<void> _reduceStock(String imei, String mobileName) async {
    try {
      final Box stockBox = Hive.isBoxOpen('stockBox')
          ? Hive.box('stockBox')
          : await Hive.openBox('stockBox');

      for (var key in stockBox.keys) {
        final val = stockBox.get(key);
        if (val is Map) {
          final itemMap = Map<String, dynamic>.from(val);
          String itemImei = (itemMap['imeiNo'] ?? itemMap['imei'] ?? '').toString().trim();
          String itemName = (itemMap['itemName'] ?? '').toString().trim();
          String status = (itemMap['status'] ?? '').toString().trim();

          bool isMatch = false;

          if (imei.isNotEmpty && itemImei.isNotEmpty && imei != 'N/A') {
            if (itemImei == imei) isMatch = true;
          } else if (mobileName.isNotEmpty && itemName.isNotEmpty) {
            if (itemName.toLowerCase() == mobileName.toLowerCase() && status == 'available') {
              isMatch = true;
            }
          }

          if (isMatch) {
            itemMap['status'] = 'sold';
            int currentQty = int.tryParse(itemMap['quantity']?.toString() ?? '1') ?? 1;
            if (currentQty > 0) {
              itemMap['quantity'] = (currentQty - 1).toString();
            }

            await stockBox.put(key, itemMap);
            break;
          }
        }
      }
    } catch (e) {
      debugPrint("Error reducing stock: $e");
    }
  }

  void dispose() {
    remarksController.dispose();
  }
}