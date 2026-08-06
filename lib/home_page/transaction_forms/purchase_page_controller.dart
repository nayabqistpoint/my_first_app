import 'package:flutter/material.dart';
import 'common/item_detail_widget.dart'; // اگر آپ کے پروجیکٹ میں پاتھ مختلف ہے تو اسے ایڈجسٹ کر لیں

class PurchasePageController {
  // آپ کا موجودہ ڈیٹا سٹرکچر
  List<Map<String, dynamic>> itemsList = [
    {
      'itemName': '',
      'imeiNo': '',
      'subTotal': '0.00',
      'calculationText': '1 × 0',
    }
  ];

  String? selectedPartyPhone;

  // 1. نئی خالی رو (Row) بنانے کا فنکشن
  bool addNewItemRow() {
    // چیک کریں کہ کیا آخری رو میں آئٹم منتخب ہوا ہے یا نہیں
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

  // 2. رو ختم کرنے کا فنکشن
  void removeItemRow(int index) {
    if (itemsList.length > 1) {
      itemsList.removeAt(index);
    }
  }

  // 3. وزٹ اوپن کرنے، ڈیٹا سیو کرنے اور "محفوظ اور نئی" کے لوپ کو سنبھالنے والا مرکزی فنکشن
  Future<void> handleItemDetailNavigation(BuildContext context, int index, {bool isEdit = false}) async {
    int currentIndex = index;
    bool shouldContinue = true;

    while (shouldContinue) {
      final initialData = isEdit ? itemsList[currentIndex] : null;

      final updatedData = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ItemDetailWidget(initialData: initialData),
        ),
      );

      if (updatedData != null && updatedData is Map<String, dynamic>) {
        // ڈیٹا لسٹ میں اپڈیٹ کریں
        itemsList[currentIndex] = updatedData;

        // اگر 'محفوظ اور نئی' (Save & New) پر کلک ہوا ہو
        if (updatedData['isSaveAndNew'] == true) {
          addNewItemRow();
          currentIndex = itemsList.length - 1;
          isEdit = false; // اگلی اینٹری کے لیے فارم ہمیشہ نیا کھولیں
        } else {
          shouldContinue = false; // 'محفوظ کریں' پر لوپ ختم
        }
      } else {
        shouldContinue = false; // اگر یوزر بیک دبائے
      }
    }
  }

  // 4. پرچیز سیو کرنے کا فنکشن
  void savePurchase() {
    // پرچیز سیو کرنے کی لاجک
  }

  void dispose() {
    // اگر کنٹرولرز وغیرہ ڈسپوز کرنے ہوں
  }
}