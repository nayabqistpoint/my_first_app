class SingleItemData {
  final String id; // ہر موبائل کی ایک منفرد آئی ڈی
  final String model; // موبائل کا ماڈل
  final String supplier; // سپلائر کا نام
  final String category; // کیٹیگری (جیسے موبائل، فریج وغیرہ)
  final int purchasePrice; // قیمتِ خرید
  final String date; // خریداری کی تاریخ
  final String imei; // آئی ایم ای آئی نمبر (IMEI)

  SingleItemData({
    required this.id,
    required this.model,
    required this.supplier,
    required this.category,
    required this.purchasePrice,
    required this.date,
    required this.imei,
  });

  // ڈیٹا کو میپ (Map) میں تبدیل کرنے کے لیے
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'model': model,
      'supplier': supplier,
      'category': category,
      'purchasePrice': purchasePrice,
      'date': date,
      'imei': imei,
    };
  }

  // میپ (Map) سے ڈیٹا واپس آبجیکٹ میں تبدیل کرنے کے لیے
  factory SingleItemData.fromMap(Map<String, dynamic> map) {
    return SingleItemData(
      id: map['id'] ?? '',
      model: map['model'] ?? '',
      supplier: map['supplier'] ?? '',
      category: map['category'] ?? 'موبائل',
      purchasePrice: map['purchasePrice'] as int? ?? 0,
      date: map['date'] ?? '',
      imei: map['imei'] ?? '',
    );
  }
}