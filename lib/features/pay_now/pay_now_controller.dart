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

  // ہائیو 'bankBox' سے ڈائریکٹ کٹوتی کرنے کا مضبوط فنکشن
  Future<void> _deductFromBankBox(String source, double amount) async {
    if (amount <= 0) return;

    try {
      var bankBox = await Hive.openBox('bankBox');
      
      // سورس کا نام اگر 'Cash' یا 'cashInHand' ہو
      if (source.trim().toLowerCase() == 'cash' || source == 'cashInHand') {
        double currentCash = (bankBox.get('cashInHand') ?? 0.0).toDouble();
        double updatedCash = currentCash - amount;
        await bankBox.put('cashInHand', updatedCash);
        debugPrint("Deducted Rs. $amount from Cash. New Balance: $updatedCash");
      } else {
        // بینک کے لیے ڈائریکٹ اصل نام (مثلاً 'aa', 'dd') کا استعمال
        String keyToUse = source.trim();
        
        // اگر ہائیو میں پرانے طریقے سے bank_ لگا ہوا ہو تو بھی سنبھال لے
        if (!bankBox.containsKey(keyToUse) && bankBox.containsKey('bank_$keyToUse')) {
          keyToUse = 'bank_$keyToUse';
        }

        double currentBankBalance = (bankBox.get(keyToUse) ?? 0.0).toDouble();
        double updatedBankBalance = currentBankBalance - amount;
        
        await bankBox.put(keyToUse, updatedBankBalance);
        debugPrint("Deducted Rs. $amount from Bank ($keyToUse). New Balance: $updatedBankBalance");
      }
    } catch (e) {
      debugPrint("Error deducting from bankBox: $e");
    }
  }

  // پیمنٹ محفوظ کرنے کا فنکشن
  Future<void> savePayment(
    BuildContext context, {
    required String paymentSource,
    List<Map<String, dynamic>>? splitPaymentsList,
  }) async {
    if (_enteredAmount <= 0) return;

    final String description = descriptionController.text.trim();
    final String currentDate = "${DateTime.now().day} اگست ${DateTime.now().year}";

    final Map<String, dynamic> transactionData = {
      'type': 'received',
      'customerPhone': customerMobileNumber,
      'customerId': customerMobileNumber,
      'amount': _enteredAmount,
      'description': description,
      'remarks': '',
      'date': currentDate,
      'discount': {'value': 0, 'isPercentage': false},
      'source': paymentSource,
      'splitPayments': splitPaymentsList ?? [],
      'hasAttachment': false,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'pending',
      'isApproved': false,
    };

    try {
      // ۱۔ ٹرانزیکشن باکس میں سیو کرنا
      var transactionBox = await Hive.openBox('transactionBox');
      await transactionBox.add(transactionData);

      // ۲۔ اگر اسپلٹ پیمنٹس موجود ہیں تو ہر سورس سے الگ الگ رقم کاٹنا
      if (splitPaymentsList != null && splitPaymentsList.isNotEmpty) {
        for (var split in splitPaymentsList) {
          String src = split['source'] ?? 'Cash';
          double amt = (split['amount'] is num)
              ? (split['amount'] as num).toDouble()
              : (double.tryParse(split['amount'].toString()) ?? 0.0);

          await _deductFromBankBox(src, amt);
        }
      } else {
        // ۳۔ سادھے موڈ میں سلیکٹ شدہ سورس (مثلاً 'aa' یا 'dd') سے کاٹنا
        await _deductFromBankBox(paymentSource, _enteredAmount);
      }
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
        content: Text("قسط کامیابی سے جمع ہو گئی اور بینک سے رقم کٹ گئی!"),
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