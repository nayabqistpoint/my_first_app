import 'package:flutter/foundation.dart';

class SalePurchaseController extends ChangeNotifier {
  // 0 = خرید (Purchase), 1 = فروخت (Sale)
  int selectedMode = 0; 
  
  // آئٹمز کی لسٹ
  List<Map<String, dynamic>> itemList = [];

  double discountValue = 0.0;
  bool isPercentageDiscount = false;

  // موڈ سیٹ کرنے کا فنکشن
  void setMode(int mode) {
    selectedMode = mode;
    notifyListeners();
  }

  // آئٹম سیو یا ایڈ کرنے کا فنکشن
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

    if (editIndex != null) {
      itemList[editIndex] = newItem;
    } else {
      itemList.add(newItem);
    }
    notifyListeners();
  }

  // آئٹم ڈیلیট کرنے کا فنکشن
  void deleteItem(int index) {
    itemList.removeAt(index);
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
    for (var item in itemList) {
      int qty = item['qty'] as int;
      double price = (selectedMode == 0) 
          ? (item['purchasePrice'] as double) 
          : (item['salePrice'] as double);
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

  // انٹری مکمل کرنے اور ڈیٹا بیس میں محفوظ کرنے کا فنکشن
  bool completeTransaction({
    String? bankSource,
    required double cashAmount,
    required double bankAmount,
  }) {
    if (itemList.isEmpty) return false;

    // یہاں آپ اپنی ڈیٹا بیس انٹری سیو کرنے کا لاجک لکھ سکتے ہیں
    
    // کامیابی کے بعد لسٹ کو کلیئر کر دیں یا جو رول آپ چاہیں
    itemList.clear();
    discountValue = 0.0;
    notifyListeners();
    return true;
  }

  // --- "محفوظ اور سیل کریں" کے لیے مطلوبہ فنکشن ---
  void shiftToSaveAndSellMode() {
    selectedMode = 1; // موڈ کو 'فروخت' (Sale) پر شفٹ کر دیا
    itemList.clear(); // اگر آپ چاہتے ہیں کہ آئٹمز صاف ہو جائیں یا قیمتیں بدلیں
    notifyListeners();
  }
}

// گلوبل کنٹرولر کا انسٹینس تاکہ پورے پروجیکٹ میں ایکسیس ہو سکے
final SalePurchaseController salePurchaseController = SalePurchaseController();