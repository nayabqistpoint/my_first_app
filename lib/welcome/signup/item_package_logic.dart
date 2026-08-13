class ItemPackageLogic {
  // مین ویری ایبلز جو UI میں شو ہوں گے
  String? mobileName;
  String? packageName;
  String? cashPrice;
  String? advanceAmount;
  String? monthlyInstallment;
  String? totalPrice;
  String? imei;
  String? checkNumber;
  String? bankName;
  
  bool isBuyStockMode = false;

  /// جب قسط کیلکولیٹر سے ڈیٹا واپس آئے گا تو یہ فنکشن اسے سیٹ کرے گا
  void updatePackageData({
    required String name,
    required String pkgName,
    String? cash,
    required String advance,
    required String installment,
    required String total,
    bool buyStock = false,
    String? stockImei,
    String? chqNumber,
    String? bnkName,
  }) {
    mobileName = name.isNotEmpty ? name : 'N/A';
    packageName = pkgName.isNotEmpty ? pkgName : 'N/A';
    cashPrice = (cash != null && cash.isNotEmpty) ? cash : '0';
    advanceAmount = advance.isNotEmpty ? advance : '0';
    monthlyInstallment = installment.isNotEmpty ? installment : '0';
    totalPrice = total.isNotEmpty ? total : '0';
    
    isBuyStockMode = buyStock;

    // بائے اسٹاک موڈ کی فیلڈ (کلر کو مکمل طور پر ہٹا دیا گیا ہے)
    imei = (buyStock && stockImei != null && stockImei.isNotEmpty) ? stockImei : null;

    // سکیورٹی چیک / بینک کی فیلڈز
    checkNumber = (chqNumber != null && chqNumber.isNotEmpty) ? chqNumber : null;
    bankName = (bnkName != null && bnkName.isNotEmpty) ? bnkName : null;
  }

  /// تمام ڈیٹا کو ایک Map کی شکل میں واپس کرنے کے لیے
  Map<String, dynamic> getPackageData() {
    return {
      'mobileName': mobileName ?? 'N/A',
      'packageName': packageName ?? 'N/A',
      'cashPrice': cashPrice ?? '0',
      'advanceAmount': advanceAmount ?? '0',
      'monthlyInstallment': monthlyInstallment ?? '0',
      'totalPrice': totalPrice ?? '0',
      'isBuyStockMode': isBuyStockMode,
      'imei': imei,
      'checkNumber': checkNumber,
      'bankName': bankName,
    };
  }

  /// ڈیٹا کو صاف کرنے (Reset) کے لیے
  void clearData() {
    mobileName = null;
    packageName = null;
    cashPrice = null;
    advanceAmount = null;
    monthlyInstallment = null;
    totalPrice = null;
    imei = null;
    checkNumber = null;
    bankName = null;
    isBuyStockMode = false;
  }
}