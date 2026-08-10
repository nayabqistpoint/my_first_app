import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'common/item_detail_widget.dart';

// پیمنٹ سورس کارڈ کی حالت (State) پڑھنے کے لیے امپورٹ
import '../../dashboard/widgets/payment_source_card.dart';

class PurchasePageController {
  List<Map<String, dynamic>> itemsList = [
    {
      'itemName': '',
      'imeiNo': '',
      'subTotal': '0.00',
      'calculationText': '1 × 0',
      'ram': '',
      'rom': '',
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

  // پیمنٹ سورس اور اسپلٹ پیمنٹس کے لیے ویری ایبلز
  String? selectedPaymentSource = 'Cash';
  List<Map<String, dynamic>> splitPaymentsList = [];

  // UI سے لائیو اسپلٹ پیمنٹ ڈیٹا پڑھنے کے لیے گلوبل کی (GlobalKey)
  final GlobalKey<PaymentSourceCardState> paymentCardKey = GlobalKey<PaymentSourceCardState>();

  bool addNewItemRow() {
    final lastItem = itemsList.last;
    if (lastItem['itemName'] != null && lastItem['itemName'].toString().isNotEmpty) {
      itemsList.add({
        'itemName': '',
        'imeiNo': '',
        'subTotal': '0.00',
        'calculationText': '1 × 0',
        'ram': '',
        'rom': '',
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

  // ٹرانزیکشن باکس، سٹاک باکس اور بینک باکس میں محفوظ کرنے کا مکمل اور محفوظ طریقہ
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

      final Box bankBox = Hive.isBoxOpen('bankBox')
          ? Hive.box('bankBox')
          : await Hive.openBox('bankBox');

      String finalPartyName = selectedPartyName ?? '';

      // کسٹمر/پارٹی کا نام نکالنا (اگر فون نمبر موجود ہو)
      if (finalPartyName.isEmpty && selectedPartyPhone != null && selectedPartyPhone!.isNotEmpty) {
        if (Hive.isBoxOpen('customerBox')) {
          final customerBox = Hive.box('customerBox');
          
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
      List<Map<String, dynamic>> minimalTransactionItems = []; // ٹرانزیکشن باکس کے لیے صرف مختصر لسٹ
      final String nowIso = DateTime.now().toIso8601String();
      final int timeKey = DateTime.now().millisecondsSinceEpoch;

      // 2. تمام تفصیلی آئٹمز کو صرف اسٹاک باکس (stockBox) میں محفوظ کرنا
      for (int i = 0; i < itemsList.length; i++) {
        var item = itemsList[i];
        if (item['itemName'] != null && item['itemName'].toString().isNotEmpty) {
          String imei = item['imeiNo']?.toString() ?? '';
          if (imei.isNotEmpty) imeiList.add(imei);

          final stockKey = "${timeKey}_${i}_${item['itemName']}";
          
          String itemRam = (item['ram'] != null && item['ram'].toString().isNotEmpty)
              ? item['ram'].toString()
              : (item['selectedRam']?.toString() ?? '');

          String itemRom = (item['rom'] != null && item['rom'].toString().isNotEmpty)
              ? item['rom'].toString()
              : (item['selectedRom']?.toString() ?? '');

          // اسٹاک باکس میں تمام تفصیلات محفوظ ہوں گی
          final stockData = {
            'itemName': item['itemName'],
            'imeiNo': imei,
            'purchasePrice': item['purchasePrice'] ?? '0',
            'salePrice': item['salePrice'] ?? '0',
            'quantity': item['quantity'] ?? '1',
            'adjustment': item['adjustment'] ?? '',
            'supplier': (item['supplier'] != null && item['supplier'].toString().isNotEmpty) 
                ? item['supplier'] 
                : finalPartyName,
            'condition': item['condition'] ?? 'new',
            'warranty': item['warranty'] ?? 0,
            'color': item['color'] ?? item['selectedColor'] ?? '',
            'ram': itemRam,
            'rom': itemRom,
            'date': nowIso,
            'status': 'available',
            'customerPhone': selectedPartyPhone ?? '',
          };

          await stockBox.put(stockKey, stockData);

          // 3. ٹرانزیکشن باکس کے لیے صرف ہلکا/مختصر رو کا ڈیٹا تیار کرنا
          minimalTransactionItems.add({
            'itemName': item['itemName'],
            'imeiNo': imei,
            'quantity': item['quantity'] ?? '1',
            'subTotal': item['subTotal'] ?? '0.00',
            'calculationText': item['calculationText'] ?? '',
          });
        }
      }

      // UI سے لائیو اسپلٹ پیمنٹس اور سورس کی لسٹ حاصل کرنا
      final cardState = paymentCardKey.currentState;
      bool isSplit = cardState?.isSplitMode ?? false;

      if (isSplit) {
        splitPaymentsList = cardState?.getSplitPaymentsList() ?? [];
      } else {
        splitPaymentsList.clear();
      }

      // 4. بینک باکس (bankBox) سے رقم منہا (Deduct) کرنا
      if (paidAmount > 0) {
        if (isSplit && splitPaymentsList.isNotEmpty) {
          for (var split in splitPaymentsList) {
            String source = split['source'] ?? 'Cash';
            double amt = (split['amount'] ?? 0.0).toDouble();
            if (amt > 0) {
              double currentBal = (bankBox.get(source) ?? 0.0).toDouble();
              await bankBox.put(source, currentBal - amt);
            }
          }
        } else {
          String source = selectedPaymentSource ?? 'Cash';
          double currentBal = (bankBox.get(source) ?? 0.0).toDouble();
          await bankBox.put(source, currentBal - paidAmount);
        }
      }

      // 5. ٹرانزیکشن باکس (transactionBox) میں مختصر آئٹم لسٹ کے ساتھ سیو کرنا
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
        'items': minimalTransactionItems, // <-- اب یہاں اضافی ڈیٹا کے بغیر صرف مختصر آئٹمز جائیں گے
        'discount': {
          'value': discountValue,
          'isPercentage': isDiscountPercentage,
        },
        'source': selectedPaymentSource,
        'splitPayments': splitPaymentsList,
        'hasAttachment': false,
        'timestamp': nowIso,
        'purchasedImeis': imeiList,
        'isCreatedByAdmin': true,
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