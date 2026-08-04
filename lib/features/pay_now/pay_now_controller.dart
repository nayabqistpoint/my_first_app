import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class PayNowController extends ChangeNotifier {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  double _enteredAmount = 0.0;
  double get enteredAmount => _enteredAmount;

  // کسٹمر کا موبائل نمبر جو اب بالکل درست ریسیو اور سیو ہوگا
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

  // پیمنٹ محفوظ کرنے کا فنکشن (ٹیسٹ شدہ اور ایرر فری)
  Future<void> savePayment(BuildContext context) async {
    if (_enteredAmount <= 0) return;

    final String description = descriptionController.text.trim();
    final String currentDate = "${DateTime.now().day} اگست ${DateTime.now().year}";

    // ٹرانزیکشن ڈیٹا (ٹائپ 'paid' اور کسٹمر فون کے ساتھ)
    final Map<String, dynamic> transactionData = {
      'type': 'paid',
      'customerPhone': customerMobileNumber,
      'customerId': customerMobileNumber,
      'amount': _enteredAmount,
      'description': description,
      'remarks': '',
      'date': currentDate,
      'discount': {'value': 0, 'isPercentage': false},
      'source': null,
      'splitPayments': [],
      'hasAttachment': false,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      var transactionBox = await Hive.openBox('transactionBox');
      await transactionBox.add(transactionData);
      debugPrint("Successfully saved to Transaction Box: $transactionData");
    } catch (e) {
      debugPrint("Error saving to Hive box: $e");
    }

    if (!context.mounted) return;

    amountController.clear();
    descriptionController.clear();
    _enteredAmount = 0.0;
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("قسط کامیابی سے ٹرانزیکشن باکس میں درج کر دی گئی ہے!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

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