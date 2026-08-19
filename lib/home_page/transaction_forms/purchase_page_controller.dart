import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'common/item_detail_widget.dart';
import '../../dashboard/widgets/payment_source_card.dart';

class PurchasePageController {
  String? targetApplicantPhone;

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

  String? selectedPaymentSource = 'Cash';
  List<Map<String, dynamic>> splitPaymentsList = [];

  final GlobalKey<PaymentSourceCardState> paymentCardKey = GlobalKey<PaymentSourceCardState>();

  Future<Box> _getBox(String boxName) async =>
      Hive.isBoxOpen(boxName) ? Hive.box(boxName) : await Hive.openBox(boxName);

  bool addNewItemRow() {
    final lastItem = itemsList.last;
    if ((lastItem['itemName'] ?? '').toString().isNotEmpty) {
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
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
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

  Future<bool> savePurchase() async {
    if (itemsList.isEmpty || (itemsList.first['itemName'] ?? '').toString().isEmpty) {
      return false;
    }

    try {
      final Box transactionBox = await _getBox('transactionBox');
      final Box stockBox = await _getBox('stockBox');
      final Box bankBox = await _getBox('bankBox');

      String finalPartyName = selectedPartyName ?? '';

      if (finalPartyName.isEmpty && selectedPartyPhone != null && selectedPartyPhone!.isNotEmpty) {
        if (Hive.isBoxOpen('customerBox')) {
          final customerBox = Hive.box('customerBox');
          final cVal = customerBox.get(selectedPartyPhone) ??
              customerBox.values.firstWhere(
                (e) => e is Map && ((e['customerPhone'] ?? e['phone'] ?? '').toString() == selectedPartyPhone),
                orElse: () => null,
              );
          if (cVal is Map) {
            finalPartyName = cVal['customerName']?.toString() ?? cVal['name']?.toString() ?? '';
          }
        }
      }

      List<String> imeiList = [];
      List<Map<String, dynamic>> minimalTransactionItems = [];
      final String nowIso = DateTime.now().toIso8601String();
      final int timeKey = DateTime.now().millisecondsSinceEpoch;

      for (int i = 0; i < itemsList.length; i++) {
        var item = itemsList[i];
        if ((item['itemName'] ?? '').toString().isNotEmpty) {
          String imei = item['imeiNo']?.toString() ?? '';
          if (imei.isNotEmpty) imeiList.add(imei);

          String itemRam = (item['ram'] ?? '').toString().isNotEmpty ? item['ram'].toString() : (item['selectedRam']?.toString() ?? '');
          String itemRom = (item['rom'] ?? '').toString().isNotEmpty ? item['rom'].toString() : (item['selectedRom']?.toString() ?? '');

          final stockData = {
            'itemName': item['itemName'],
            'imeiNo': imei,
            'purchasePrice': item['purchasePrice'] ?? '0',
            'salePrice': item['salePrice'] ?? '0',
            'quantity': item['quantity'] ?? '1',
            'adjustment': item['adjustment'] ?? '',
            'supplier': (item['supplier'] ?? '').toString().isNotEmpty ? item['supplier'] : finalPartyName,
            'condition': item['condition'] ?? 'new',
            'warranty': item['warranty'] ?? 0,
            'color': item['color'] ?? item['selectedColor'] ?? '',
            'ram': itemRam,
            'rom': itemRom,
            'date': nowIso,
            'status': 'available',
            'customerPhone': selectedPartyPhone ?? '',
          };

          await stockBox.put("${timeKey}_${i}_${item['itemName']}", stockData);

          minimalTransactionItems.add({
            'itemName': item['itemName'],
            'imeiNo': imei,
            'quantity': item['quantity'] ?? '1',
            'subTotal': item['subTotal'] ?? '0.00',
            'calculationText': item['calculationText'] ?? '',
          });
        }
      }

      final cardState = paymentCardKey.currentState;
      bool isSplit = cardState?.isSplitMode ?? false;
      splitPaymentsList = isSplit ? (cardState?.getSplitPaymentsList() ?? []) : [];

      String? picturePath = cardState?.attachedImagePath ?? cardState?.imagePath;
      bool hasPicture = picturePath != null && picturePath.trim().isNotEmpty;
      String actualDescription = cardState?.noteController.text.trim() ?? cardState?.descriptionController.text.trim() ?? '';

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

      final transactionData = {
        'type': 'purchase',
        'customerPhone': selectedPartyPhone ?? '',
        'customerId': selectedPartyPhone ?? '',
        'partyName': finalPartyName,
        'amount': grandTotalAmount,
        'paidAmount': paidAmount,
        'remainingBalance': remainingBalance,
        'description': actualDescription,
        'remarks': imeiList.join(','),
        'date': nowIso,
        'items': minimalTransactionItems,
        'discount': {
          'value': discountValue,
          'isPercentage': isDiscountPercentage,
        },
        'source': selectedPaymentSource,
        'splitPayments': splitPaymentsList,
        'hasPicture': hasPicture,
        'picturePath': picturePath,
        'timestamp': nowIso,
        'purchasedImeis': imeiList,
        'isCreatedByAdmin': true,
      };

      await transactionBox.put(timeKey.toString(), transactionData);

      final String phoneToUpdate = (targetApplicantPhone ?? selectedPartyPhone ?? '').trim();

      if (phoneToUpdate.isNotEmpty && itemsList.isNotEmpty) {
        try {
          final Box packageBox = await _getBox('packageBox');
          final firstItem = itemsList.first;

          final String purchasedImei = firstItem['imeiNo']?.toString() ?? '';
          final String purchasedName = firstItem['itemName']?.toString() ?? '';
          final String purchasedSalePrice = firstItem['salePrice']?.toString() ?? '';

          dynamic targetKey;
          Map<String, dynamic>? targetData;

          if (packageBox.containsKey(phoneToUpdate)) {
            targetKey = phoneToUpdate;
            targetData = Map<String, dynamic>.from(packageBox.get(phoneToUpdate) as Map);
          } else {
            for (var key in packageBox.keys) {
              final val = packageBox.get(key);
              if (val is Map && (val['customerPhone'] ?? val['phone'] ?? '').toString().trim() == phoneToUpdate) {
                targetKey = key;
                targetData = Map<String, dynamic>.from(val);
                break;
              }
            }
          }

          if (targetKey != null && targetData != null) {
            if (purchasedImei.isNotEmpty) targetData['imei'] = purchasedImei;
            if (purchasedName.isNotEmpty && purchasedName != "موبائل / آئٹم") targetData['mobileName'] = purchasedName;
            if (purchasedSalePrice.isNotEmpty) targetData['cashPrice'] = purchasedSalePrice;

            await packageBox.put(targetKey, targetData);
          }
        } catch (e) {
          debugPrint("Error in Mapping packageBox fields: $e");
        }
      }

      return true;
    } catch (e) {
      debugPrint("Save Purchase Error: $e");
      return false;
    }
  }

  void dispose() {}
}