class SingleItemData {
  final String id;
  final String billId;          // پیرنٹ بل آئی ڈی
  final String model;
  final String category;
  final int purchasePrice;
  final int quantity;          // تعداد
  final String imei;           // اس مخصوص موبائل کا IMEI
  final String supplier;
  final String date;

  SingleItemData({
    required this.id,
    required this.billId,
    required this.model,
    required this.category,
    required this.purchasePrice,
    required this.quantity,
    required this.imei,
    required this.supplier,
    required this.date,
  });
}

// سپلائر کا ڈیٹا جو ہوم پیج پر سنک ہوگا
class SupplierProfile {
  final String name;
  final String phone;
  final int balance; // پلس کا مطلب ہم نے لینے ہیں، مائنس کا مطلب ہم نے دینے ہیں

  SupplierProfile({
    required this.name,
    required this.phone,
    this.balance = 0,
  });
}