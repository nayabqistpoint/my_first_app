import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../dashboard/widgets/payment_source_card.dart';
import '../common/discount_widget.dart'; // 🔥 DiscountWidget امپورٹ

class PaymentInController {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  
  final FocusNode amountFocusNode = FocusNode();

  final ValueNotifier<bool> hasAmountEntered = ValueNotifier<bool>(false);
  final ValueNotifier<double> currentAmountNotifier = ValueNotifier<double>(0.0);
  
  final ValueNotifier<bool> isSaving = ValueNotifier<bool>(false);

  // 🔥 PaymentSourceCard کے ساتھ رابطہ قائم کرنے والی GlobalKey 🔥
  final GlobalKey<PaymentSourceCardState> paymentSourceCardKey = GlobalKey<PaymentSourceCardState>();

  double _discountValue = 0.0;
  bool _isPercentageDiscount = false;
  String _selectedDiscountCategory = 'Discounts'; // 🔥 منتخب کردہ ڈسکاؤنٹ/انکم کیٹیگری
  
  String? _selectedSource = 'Cash';

  String? get selectedPaymentSource => _selectedSource;

  void updateSelectedSource(String? newSource) {
    _selectedSource = newSource;
  }

  PaymentInController() {
    amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    final text = amountController.text.trim();
    final parsedAmount = double.tryParse(text) ?? 0.0;
    
    currentAmountNotifier.value = parsedAmount;
    hasAmountEntered.value = text.isNotEmpty;
  }

  // 🔥 3 پیرامیٹرز (کیٹیگری نام، رقم، اور فیصد) کے ساتھ اپ ڈیٹ شدہ ڈسکاؤنٹ فنکشن 🔥
  void updateDiscount(String categoryName, double value, bool isPercentage) {
    _selectedDiscountCategory = categoryName;
    _discountValue = value;
    _isPercentageDiscount = isPercentage;
  }

  void dispose() {
    amountController.dispose();
    remarksController.dispose();
    amountFocusNode.dispose();
    hasAmountEntered.dispose();
    currentAmountNotifier.dispose();
    isSaving.dispose();
  }

  Future<void> savePaymentIn(BuildContext context, {String? customerId}) async {
    if (isSaving.value) return;

    String amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('براہ کرم رقم درج کریں')),
      );
      return;
    }

    isSaving.value = true;

    double totalAmount = double.tryParse(amountText) ?? 0.0;
    String remarks = remarksController.text.trim();

    // 🔥 ۱۔ ڈسکاؤنٹ کی رقم کا حساب لگانا 🔥
    double calculatedDiscountAmount = 0.0;
    if (_isPercentageDiscount) {
      calculatedDiscountAmount = (totalAmount * _discountValue) / 100;
    } else {
      calculatedDiscountAmount = _discountValue;
    }

    // 🔥 ۲۔ کیش یا بینک میں جمع ہونے والی اصل بقایا رقم 🔥
    double netAmountToReceive = totalAmount - calculatedDiscountAmount;
    if (netAmountToReceive < 0) netAmountToReceive = 0.0;

    String cleanPhone = (customerId ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final String nowIso = DateTime.now().toIso8601String();

    // 🔥 لائیو PaymentSourceCard سے ڈیٹا (سنگل یا اسپلٹ) حاصل کرنا 🔥
    final cardState = paymentSourceCardKey.currentState;
    bool isSplit = cardState?.isSplitMode ?? false;
    List<Map<String, dynamic>> splitList = cardState?.getSplitPaymentsList() ?? [];

    final Map<String, dynamic> transactionData = {
      'type': 'received', 
      'customerPhone': cleanPhone,
      'customerId': cleanPhone, 
      'amount': totalAmount,
      'netAmount': netAmountToReceive,
      'description': remarks,
      'remarks': remarks,
      'date': nowIso,
      'discount': {
        'category': _selectedDiscountCategory,
        'value': _discountValue,
        'amount': calculatedDiscountAmount,
        'isPercentage': _isPercentageDiscount,
      },
      'source': _selectedSource ?? 'Cash',
      'splitPayments': isSplit ? splitList : [],
      'hasAttachment': false,
      'timestamp': nowIso,
    };

    try {
      // ۱۔ ٹرانزیکشن باکس میں اندراج
      var txnBox = Hive.box('transactionBox');
      await txnBox.add(transactionData);

      // ۲۔ ڈائریکٹ ہائیو کے 'bankBox' میں مائنس ڈسکاؤنٹ شدہ رقم (Net Amount) جمع کرنا
      var bankBox = Hive.box('bankBox');

      if (isSplit && splitList.isNotEmpty) {
        // اسپلٹ موڈ: تمام منتخب شدہ بینکس/کیش میں ان کی اپنی لائیو رقم جمع کرنا
        for (var split in splitList) {
          String srcKey = split['source'] ?? 'Cash';
          double splitAmt = (split['amount'] is num)
              ? (split['amount'] as num).toDouble()
              : (double.tryParse(split['amount'].toString()) ?? 0.0);

          if (splitAmt > 0) {
            double currentBalance = (bankBox.get(srcKey, defaultValue: 0.0) as num).toDouble();
            await bankBox.put(srcKey, currentBalance + splitAmt);
          }
        }
      } else {
        // سنگل موڈ: منتخب کردہ مخصوص بینک یا کیش میں مائنس ڈسکاؤنٹ رقم جمع کرنا
        String sourceKey = _selectedSource ?? 'Cash';
        double currentBalance = (bankBox.get(sourceKey, defaultValue: 0.0) as num).toDouble();
        await bankBox.put(sourceKey, currentBalance + netAmountToReceive);
      }

      // 🔥 ۳۔ ڈسکاؤنٹ کی رقم کو 'expenseBox' کی منتخب کردہ کیٹیگری میں ریکارڈ کرنا 🔥
      if (calculatedDiscountAmount > 0) {
        DiscountWidget.recordDiscountInHive(
          categoryName: _selectedDiscountCategory,
          amount: calculatedDiscountAmount,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('کامیاب! پیمنٹ اِن محفوظ ہو گئی: Rs. ${netAmountToReceive.toStringAsFixed(0)}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خرابی پیش آئی: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (context.mounted) {
        isSaving.value = false;
      }
    }
  }
}