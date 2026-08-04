import 'package:flutter/material.dart';

class PayNowController extends ChangeNotifier {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  double _enteredAmount = 0.0;
  double get enteredAmount => _enteredAmount;

  // کسٹمر کا موبائل نمبر جو بطور آئی ڈی استعمال ہوگا
  String customerMobileNumber = "";

  PayNowController() {
    amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    double val = double.tryParse(amountController.text) ?? 0.0;
    if (_enteredAmount != val) {
      _enteredAmount = val;
      notifyListeners();
    }
  }

  // پیمنٹ محفوظ کرنے کا فنکشن (ساتھ context لے کر پچھلے پیج پر واپس جائے گا)
  void savePayment(BuildContext context) {
    if (_enteredAmount <= 0) return;

    final String description = descriptionController.text.trim();

    // ٹرانزیکشن ڈیٹا جو ڈیٹا بیس میں جائے گا
    final Map<String, dynamic> transactionData = {
      'customerMobile': customerMobileNumber,
      'amount': _enteredAmount,
      'description': description,
      'timestamp': DateTime.now().toIso8601String(),
      'isVerified': false, // پینڈنگ / مدھم اسٹیٹس
    };

    // --- ٹیسٹنگ لاجک ---
    debugPrint("Saved Transaction to DB: $transactionData");

    // فیلڈز اور اماؤنٹ صاف کریں
    amountController.clear();
    descriptionController.clear();
    _enteredAmount = 0.0;
    notifyListeners();

    // 1. پیغام دکھائیں
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("قسط کامیابی سے درج کر لی گئی ہے (تصدیق کے لیے پینڈنگ)"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // 2. صفحہ بند کر کے واپس پیچھے لیجر پر چلے جائیں
    Navigator.pop(context);
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

final PayNowController payNowController = PayNowController();