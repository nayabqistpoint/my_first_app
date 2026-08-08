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

  // رو کلک کرنے پر آئٹم ڈیٹیل وجٹ کھولنے کی لاجک
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

  // ✅ ٹرانزیکشن باکس اور سٹاک باکس دونوں میں محفوظ کرنے کا مکمل اور محفوظ طریقہ
  Future<bool> savePurchase() async {
    if (itemsList.isEmpty || (itemsList.first['itemName'] ?? '').toString().isEmpty) {
      return false;
    }

    try {
      // 1. باکسز کو محفوظ طریقے سے گیٹ (Get/Open) کرنا
      final Box transactionBox = Hive.isBoxOpen('transactionBox') 
          ? Hive.box('transactionBox') 
          : await Hive.openBox('transactionBox');
          
      final Box stockBox = Hive.isBoxOpen('stockBox') 
          ? Hive.box('stockBox') 
          : await Hive.openBox('stockBox');

      String finalPartyName = selectedPartyName ?? '';

      // کسٹمر/پارٹی کا نام نکالنا (اگر فون نمبر موجود ہو)
      if (finalPartyName.isEmpty && selectedPartyPhone != null && selectedPartyPhone!.isNotEmpty) {
        if (Hive.isBoxOpen('customerBox')) {
          final customerBox = Hive.box('customerBox');
          
          // موبائل نمبر کی بنیاد پر کسٹمر تلاش کرنا
          if (customerBox.containsKey(selectedPartyPhone)) {
            final cData = Map<String, dynamic>.from(customerBox.get(selectedPartyPhone) as Map);
            finalPartyName = cData['customerName']?.toString() ?? cData['name']?.toString() ?? '';
          } else {
            final matchedCustomer = customerBox.values.firstWhere(
              (element) {
                if (element is! Map) return false;
                final data = Map<String, dynamic>.from(element);
                String phone = data['customerPhone']?.toString() ?? data['phone']?.toString() ?? '';
                return phone == selectedPartyPhone;
              },
              orElse: () => null,
            );

            if (matchedCustomer != null) {
              final Map<String, dynamic> cData = Map<String, dynamic>.from(matchedCustomer as Map);
              finalPartyName = cData['customerName']?.toString() ?? cData['name']?.toString() ?? '';
            }
          }
        }
      }

      List<String> imeiList = [];
      final String nowIso = DateTime.now().toIso8601String();
      final int timeKey = DateTime.now().millisecondsSinceEpoch;

      // ✅ 2. تمام آئٹمز کو سٹاک باکس (stockBox) میں محفوظ کرنا (بغیر کسی فیلڈ مسنگ کے)
      for (int i = 0; i < itemsList.length; i++) {
        var item = itemsList[i];
        if (item['itemName'] != null && item['itemName'].toString().isNotEmpty) {
          String imei = item['imeiNo']?.toString() ?? '';
          if (imei.isNotEmpty) imeiList.add(imei);

          // سٹاک کے لیے منفرد کی (Unique Key)
          final stockKey = "${timeKey}_${i}_${item['itemName']}";
          
          final stockData = {
            'itemName': item['itemName'],
            'imeiNo': imei,
            'purchasePrice': item['purchasePrice'] ?? '0',
            'salePrice': item['salePrice'] ?? '0',
            'quantity': item['quantity'] ?? '1',
            'adjustment': item['adjustment'] ?? '', // ایڈجسٹمنٹ بھی محفوظ کی گئی
            'supplier': (item['supplier'] != null && item['supplier'].toString().isNotEmpty) 
                ? item['supplier'] 
                : finalPartyName,
            'condition': item['condition'] ?? 'new',
            'warranty': item['warranty'] ?? 0,
            'color': item['color'] ?? item['selectedColor'] ?? '',
            'date': nowIso,
            'status': 'available', // سٹاک میں دستیاب ہے
            'customerPhone': selectedPartyPhone ?? '', // ربط کے لیے
          };

          await stockBox.put(stockKey, stockData);
        }
      }

      // ✅ 3. ٹرانزیکشن باکس (transactionBox) میں مکمل خرید کا ریکارڈ سیو کرنا
      final transactionKey = timeKey.toString();

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
        'items': itemsList, // آئٹمز کی مکمل لسٹ
        'discount': {
          'value': discountValue,
          'isPercentage': isDiscountPercentage,
        },
        'source': null,
        'splitPayments': [],
        'hasAttachment': false,
        'timestamp': nowIso,
        'purchasedImeis': imeiList,
        'isCreatedByAdmin': false,
      };

      await transactionBox.put(transactionKey, transactionData);
      return true;
    } catch (e) {
      debugPrint("Save Purchase Error: $e");
      return false;
    }
  }

  void dispose() {}
}