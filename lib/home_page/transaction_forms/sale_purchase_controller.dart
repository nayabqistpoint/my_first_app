import 'package:flutter/foundation.dart';

class SalePurchaseController extends ChangeNotifier {
  // 0 = خرید (Purchase), 1 = فروخت (Sale)
  int selectedMode = 0; 
  
  // خرید اور فروخت کے لیے الگ الگ لسٹیں تاکہ ڈیٹا محفوظ رہے
  List<Map<String, dynamic>> purchaseItemList = [];
  List<Map<String, dynamic>> saleItemList = [];

  double discountValue = 0.0;
  bool isPercentageDiscount = false;

  // پرانے UI کی بقا کے لیے گیٹر تاکہ جہاں بھی 'itemList' استعمال ہو رہا ہے وہ ایرر نہ دے
  List<Map<String, dynamic>> get itemList {
    return selectedMode == 0 ? purchaseItemList : saleItemList;
  }

  // موڈ سیٹ کرنے کا فنکشن (ٹॉगल کے ذریعے عام سوئچنگ)
  void setMode(int mode) {
    selectedMode = mode;
    notifyListeners();
  }

  // آئٹم سیو یا ایڈ کرنے کا فنکشن
  void saveItem({
    int? editIndex,
    required String model,
    required int qty,
    required double purchasePrice,
    required double salePrice,
    required String desc,
    required String imei,
    required String category,
  }) {
    final newItem = {
      'model': model,
      'qty': qty,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'desc': desc,
      'imei': imei,
      'category': category,
    };

    if (selectedMode == 0) {
      if (editIndex != null && editIndex >= 0 && editIndex < purchaseItemList.length) {
        purchaseItemList[editIndex] = newItem;
      } else {
        purchaseItemList.add(newItem);
      }
    } else {
      if (editIndex != null && editIndex >= 0 && editIndex < saleItemList.length) {
        saleItemList[editIndex] = newItem;
      } else {
        saleItemList.add(newItem);
      }
    }
    notifyListeners();
  }

  // آئٹم ڈیلیٹ کرنے کا فنکشن
  void deleteItem(int index) {
    if (selectedMode == 0) {
      if (index >= 0 && index < purchaseItemList.length) {
        purchaseItemList.removeAt(index);
      }
    } else {
      if (index >= 0 && index < saleItemList.length) {
        saleItemList.removeAt(index);
      }
    }
    notifyListeners();
  }

  // ڈسکاؤنٹ سیٹ کرنے کا فنکشن
  void setDiscount(double value, bool isPercentage) {
    discountValue = value;
    isPercentageDiscount = isPercentage;
    notifyListeners();
  }

  // سب ٹوٹل نکالنے کا حساب
  double get subTotal {
    double total = 0.0;
    final list = itemList; 
    for (var item in list) {
      int qty = (item['qty'] as num?)?.toInt() ?? 0;
      double price = (selectedMode == 0) 
          ? ((item['purchasePrice'] as num?)?.toDouble() ?? 0.0) 
          : ((item['salePrice'] as num?)?.toDouble() ?? 0.0);
      total += qty * price;
    }
    return total;
  }

  // ڈسکاؤنٹ کی رقم نکالنا
  double get discountAmount {
    if (isPercentageDiscount) {
      return (subTotal * discountValue) / 100;
    } else {
      return discountValue;
    }
  }

  // گرینڈ ٹوٹل
  double get grandTotal {
    double finalVal = subTotal - discountAmount;
    return finalVal < 0 ? 0 : finalVal;
  }

  // انٹری مکمل کرنے کا فنکشن
  bool completeTransaction({
    String? bankSource,
    required double cashAmount,
    required double bankAmount,
  }) {
    if (itemList.isEmpty) return false;

    if (selectedMode == 0) {
      purchaseItemList.clear();
    } else {
      saleItemList.clear();
    }
    discountValue = 0.0;
    isPercentageDiscount = false;
    notifyListeners();
    return true;
  }

  // --- "محفوظ کریں اور سیل کریں" کا مضبوط اور درست فنکشن ---
  void shiftToSaveAndSellMode() {
    // 1. پرچیز لسٹ کا گہرا کاپی (Deep copy) بنائیں تاکہ ڈیٹا محفوظ طریقے سے سیل لسٹ میں جائے
    saleItemList = purchaseItemList.map((item) => Map<String, dynamic>.from(item)).toList();
    
    // 2. موڈ کو فروخت (1) پر سیٹ کریں
    selectedMode = 1; 
    
    // 3. ڈسکاؤنٹ ری سیٹ کریں
    discountValue = 0.0;
    isPercentageDiscount = false;

    notifyListeners();
  }
}

// گلوبل کنٹرولر کا انسٹینس
final SalePurchaseController salePurchaseController = SalePurchaseController();