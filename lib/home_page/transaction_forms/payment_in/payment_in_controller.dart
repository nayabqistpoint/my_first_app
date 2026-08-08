import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PaymentInController {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  
  final FocusNode amountFocusNode = FocusNode();

  final ValueNotifier<bool> hasAmountEntered = ValueNotifier<bool>(false);
  final ValueNotifier<double> currentAmountNotifier = ValueNotifier<double>(0.0);
  
  final ValueNotifier<bool> isSaving = ValueNotifier<bool>(false);

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

  void updateDiscount(double value, bool isPercentage) {
    _discountValue = value;
    _isPercentageDiscount = isPercentage;
  }

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

    double amount = double.tryParse(amountText) ?? 0.0;
    String remarks = remarksController.text.trim();

    // موبائل نمبر کو مکمل صاف کرنا تاکہ یونیک کی میچنگ میں کوئی خامی نہ رہے
    String cleanPhone = (customerId ?? '').replaceAll(RegExp(r'[^0-9]'), '');

    // ISO تاریخ کا یکساں فارمیٹ
    final String nowIso = DateTime.now().toIso8601String();

    final Map<String, dynamic> transactionData = {
      'type': 'received', 
      'customerPhone': cleanPhone,
      'customerId': cleanPhone, 
      'amount': amount,
      'description': remarks,
      'remarks': remarks,
      'date': nowIso,
      'discount': {
        'value': _discountValue,
        'isPercentage': _isPercentageDiscount,
      },
      'source': _selectedSource ?? 'Cash',
      'splitPayments': _splitPayments,
      'hasAttachment': false,
      'timestamp': nowIso,
    };

    try {
      // 1. ٹرانزیکشن باکس میں اینٹری
      var txnBox = Hive.box('transactionBox');
      await txnBox.add(transactionData);

      // 2. کیش یا بینک کے بیلنس میں رقم کا اضافہ
      var bankBox = Hive.box('bankBox');
      String sourceKey = _selectedSource ?? 'Cash';
      double currentBalance = (bankBox.get(sourceKey, defaultValue: 0.0) as num).toDouble();
      await bankBox.put(sourceKey, currentBalance + amount);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('کامیاب! پیمنٹ اِن محفوظ ہو گئی: Rs. $amount'),
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