import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PaymentInController {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  
  final FocusNode amountFocusNode = FocusNode();

  final ValueNotifier<bool> hasAmountEntered = ValueNotifier<bool>(false);
  final ValueNotifier<double> currentAmountNotifier = ValueNotifier<double>(0.0);

  // ڈسکاؤنٹ اور سورس سلیکٹر کی ویلیوز کو ہولڈ کرنے کے لیے ویری ایبلز
  double _discountValue = 0.0;
  bool _isPercentageDiscount = false;
  
  String? _selectedSource;
  List<Map<String, dynamic>> _splitPayments = [];

  PaymentInController() {
    amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    final text = amountController.text.trim();
    final parsedAmount = double.tryParse(text) ?? 0.0;
    
    currentAmountNotifier.value = parsedAmount;
    hasAmountEntered.value = text.isNotEmpty;
  }

  // ڈسکاؤنٹ اپ ڈیٹ کرنے کا فنکشن (DiscountWidget سے کال ہوگا)
  void updateDiscount(double value, bool isPercentage) {
    _discountValue = value;
    _isPercentageDiscount = isPercentage;
  }

  // سورس یا سپلٹ پیمنٹ اپ ڈیٹ کرنے کا فنکشن (SourceSelecter سے کال ہوگا)
  void updateSourceSplit(String? source, List<Map<String, dynamic>> splits) {
    _selectedSource = source;
    _splitPayments = splits;
  }

  void dispose() {
    amountController.dispose();
    remarksController.dispose();
    amountFocusNode.dispose();
    hasAmountEntered.dispose();
    currentAmountNotifier.dispose();
  }

  // ٹرانزیکشن کو ہائیو کے 'transactionBox' میں محفوظ کرنے کا فنکشن
  Future<void> savePaymentIn(BuildContext context, {String? customerId}) async {
    String amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('براہ کرم رقم درج کریں')),
      );
      return;
    }

    double amount = double.tryParse(amountText) ?? 0.0;
    String remarks = remarksController.text.trim();

    // ٹرانزیکشن کا مکمل ڈیٹا میپ (جس میں type کو 'received' رکھا گیا ہے تاکہ لیجر میں 'ملی' والی سائیڈ شو ہو)
    final Map<String, dynamic> transactionData = {
      'type': 'received', 
      'customerId': customerId ?? 'default_customer', 
      'amount': amount,
      'description': remarks, // مڈل سیکشن میں یہ description یا remarks کے نام سے ریڈ ہوتا ہے
      'remarks': remarks,
      'date': '02 اگست 2026', // موجودہ تاریخ یا DateTime.now().toString()
      'discount': {
        'value': _discountValue,
        'isPercentage': _isPercentageDiscount,
      },
      'source': _selectedSource,
      'splitPayments': _splitPayments,
      'hasAttachment': false,
    };

    try {
      // ہائیو کے 'transactionBox' میں ڈیٹا محفوظ کرنا
      var box = Hive.box('transactionBox');
      await box.add(transactionData);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('کامیاب! پیمنٹ محفوظ ہو گئی: Rs. $amount')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خرابی پیش آئی: $e')),
        );
      }
    }
  }
}