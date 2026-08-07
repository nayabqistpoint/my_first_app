import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'common/item_detail_widget.dart';

class PurchasePageController {
  List<Map<String, dynamic>> itemsList = [
    {
      'itemName': '',
      'imeiNo': '',
      'subTotal': '0.00',
      'calculationText': '1 × 0',
    }
  ];

  String? selectedPartyPhone;
  String? selectedPartyName;

  double grandTotalAmount = 0.0;
  double paidAmount = 0.0;
  double remainingBalance = 0.0;
  double discountValue = 0.0;
  bool isDiscountPercentage = false;
  String descriptionText = '';

  bool addNewItemRow() {
    final lastItem = itemsList.last;
    if (lastItem['itemName'] != null && lastItem['itemName'].toString().isNotEmpty) {
      itemsList.add({
        'itemName': '',
        'imeiNo': '',
        'subTotal': '0.00',
        'calculationText': '1 × 0',
      });
      return true;
    }
    return false;
  }

  void removeItemRow(int index) {
    if (itemsList.length > 1) {
      itemsList.removeAt(index);
    }
  }

  // رو کلک کرنے پر آئٹم ڈیٹیل وزٹ کھولنے کی لاجک
  Future<void> handleItemDetailNavigation(BuildContext context, int index, {bool isEdit = false}) async {
    int currentIndex = index;
    bool shouldContinue = true;

    while (shouldContinue) {
      if (!context.mounted) break;

      final initialData = isEdit ? itemsList[currentIndex] : null;

      final updatedData = await Navigator.push<Map<String, dynamic>>(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ItemDetailWidget(initialData: initialData),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 150),
        ),
      );

      if (updatedData != null) {
        itemsList[currentIndex] = updatedData;

        if (updatedData['isSaveAndNew'] == true) {
          addNewItemRow();
          currentIndex = itemsList.length - 1;
          isEdit = false;
        } else {
          shouldContinue = false;
        }
      } else {
        shouldContinue = false;
      }
    }
  }

  // ✅ ٹرانزیکشن باکس اور سٹاک باکس دونوں میں محفوظ کرنے کا مکمل طریقہ
  Future<bool> savePurchase() async {
    if (itemsList.isEmpty || (itemsList.first['itemName'] ?? '').toString().isEmpty) {
      return false;
    }

    try {
      // 1. Boxes Open کریں
      final transactionBox = await Hive.openBox('transactionBox');
      final stockBox = await Hive.openBox('stockBox');

      String finalPartyName = selectedPartyName ?? '';

      // کسٹمر کا نام نکالنا
      if (finalPartyName.isEmpty && selectedPartyPhone != null) {
        if (Hive.isBoxOpen('customerBox')) {
          final customerBox = Hive.box('customerBox');
          final matchedCustomer = customerBox.values.firstWhere(
            (element) {
              final data = Map<String, dynamic>.from(element as Map);
              String phone = data['customerPhone']?.toString() ?? data['phone']?.toString() ?? '';
              return phone == selectedPartyPhone;
            },
            orElse: () => null,
          );

          if (matchedCustomer != null) {
            final Map<String, dynamic> cData = Map<String, dynamic>.from(matchedCustomer as Map);
            finalPartyName = cData['customerName']?.toString() ?? 
                             cData['name']?.toString() ?? 
                             cData['partyName']?.toString() ?? '';
          }
        }
      }

      List<String> imeiList = [];
      
      // ✅ 2. تمام آئٹمز کو stockBox میں محفوظ کرنا
      for (var item in itemsList) {
        if (item['itemName'] != null && item['itemName'].toString().isNotEmpty) {
          String imei = item['imeiNo']?.toString() ?? '';
          if (imei.isNotEmpty) imeiList.add(imei);

          final stockKey = "${DateTime.now().millisecondsSinceEpoch}_${item['itemName']}";
          
          final stockData = {
            'itemName': item['itemName'],
            'imeiNo': imei,
            'purchasePrice': item['purchasePrice'] ?? '0',
            'salePrice': item['salePrice'] ?? '0',
            'quantity': item['quantity'] ?? '1',
            'supplier': item['supplier'] ?? finalPartyName,
            'condition': item['condition'] ?? 'new',
            'warranty': item['warranty'] ?? 0,
            'color': item['color'] ?? '',
            'date': DateTime.now().toIso8601String(),
            'status': 'available', // سٹاک میں موجود ہے
          };

          await stockBox.put(stockKey, stockData);
        }
      }

      // ✅ 3. ٹرانزیکشن باکس (transactionBox) میں تفصیلات محفوظ کرنا
      final key = DateTime.now().millisecondsSinceEpoch.toString();
      final nowIso = DateTime.now().toIso8601String();

      final transactionData = {
        'type': 'purchase',
        'customerPhone': selectedPartyPhone ?? '',
        'customerId': selectedPartyPhone ?? '',
        'partyName': finalPartyName,
        'amount': grandTotalAmount,
        'paidAmount': paidAmount,
        'remainingBalance': remainingBalance,
        'description': descriptionText,
        'remarks': imeiList.join(','),
        'date': nowIso,
        'items': itemsList, // آئٹمز کی لسٹ محفوظ کی
        'discount': {
          'value': discountValue,
          'isPercentage': isDiscountPercentage
        },
        'source': null,
        'splitPayments': [],
        'hasAttachment': false,
        'timestamp': nowIso,
        'purchasedImeis': imeiList,
        'isCreatedByAdmin': false,
      };

      await transactionBox.put(key, transactionData);
      return true;
    } catch (e) {
      debugPrint("Save Purchase Error: $e");
      return false;
    }
  }

  void dispose() {}
}