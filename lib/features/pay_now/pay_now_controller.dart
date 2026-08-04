import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class PayNowController extends ChangeNotifier {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  double _enteredAmount = 0.0;
  double get enteredAmount => _enteredAmount;

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

  // پیمنٹ محفوظ کرنے کا فنکشن (اب یہ باقاعدہ پینڈنگ سٹیٹس کے ساتھ سیو ہوگی)
  Future<void> savePayment(BuildContext context) async {
    if (_enteredAmount <= 0) return;

    final String description = descriptionController.text.trim();
    final String currentDate = "${DateTime.now().day} اگست ${DateTime.now().year}";

    // یہاں ہم نے ڈیٹا بیس میں باقاعدہ پینڈنگ کی فیلڈز ایڈ کر دی ہیں
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
      'status': 'pending',     // 👈 یہ بتائے گا کہ انٹری پینڈنگ ہے
      'isApproved': false,     // 👈 یہ بتائے گا کہ ابھی ایڈمن منظوری باقی ہے
    };

    try {
      var transactionBox = await Hive.openBox('transactionBox');
      await transactionBox.add(transactionData);
      debugPrint("Successfully saved as Pending: $transactionData");
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
        content: Text("قسط کامیابی سے پینڈنگ لسٹ میں جمع ہو گئی ہے!"),
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