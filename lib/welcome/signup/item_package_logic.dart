// فائل کا نام: item_package_logic.dart

class ItemPackageLogic {
  // یہ ویری ایبلز کیلکولیٹر سے آنے والا ڈیٹا محفوظ کریں گے
  String? mobileName;
  String? advanceAmount;
  String? monthlyInstallment;
  String? totalPrice;
  String? imei;
  String? color;
  bool isBuyStockMode = false;

  // یہ فنکشن سائن اپ پیج کو فائنل ڈیٹا بھیجے گا
  Map<String, dynamic> getPackageData() {
    return {
      'mobileName': mobileName ?? '',
      'advanceAmount': advanceAmount ?? '',
      'monthlyInstallment': monthlyInstallment ?? '',
      'totalPrice': totalPrice ?? '',
      // اگر بائے سٹاک موڈ ہے تو IMEI اور Color جائے گا، ورنہ N/A
      'imei': isBuyStockMode ? (imei ?? '') : 'N/A',
      'color': isBuyStockMode ? (color ?? '') : 'N/A',
      'isBuyStockMode': isBuyStockMode,
    };
  }
}