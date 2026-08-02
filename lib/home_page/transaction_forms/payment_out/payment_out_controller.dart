import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PaymentOutController {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  
  final FocusNode amountFocusNode = FocusNode();

  final ValueNotifier<bool> hasAmountEntered = ValueNotifier<bool>(false);
  final ValueNotifier<double> currentAmountNotifier = ValueNotifier<double>(0.0);

  double _discountValue = 0.0;
  bool _isPercentageDiscount = false;
  
  String? _selectedSource;
  List<Map<String, dynamic>> _splitPayments = [];

  PaymentOutController() {
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
  }

  // ٹرانزیکشن کو ہائیو کے 'transactionBox' میں 'paid' ٹائپ کے ساتھ محفوظ کرنے کا فنکشن
  Future<void> savePaymentOut(BuildContext context, {String? customerId}) async {
    String amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('براہ کرم رقم درج کریں')),
      );
      return;
    }

    double amount = double.tryParse(amountText) ?? 0.0;
    String remarks = remarksController.text.trim();

    final Map<String, dynamic> transactionData = {
      'type': 'paid', // پیمنٹ آؤت کے لیے 'paid' تاکہ دی گئی رقم شو ہو
      'customerId': customerId ?? 'default_customer', 
      'amount': amount,
      'description': remarks,
      'remarks': remarks,
      'date': '02 اگست 2026',
      'discount': {
        'value': _discountValue,
        'isPercentage': _isPercentageDiscount,
      },
      'source': _selectedSource,
      'splitPayments': _splitPayments,
      'hasAttachment': false,
    };

    try {
      var box = Hive.box('transactionBox');
      await box.add(transactionData);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('کامیاب! پیمنٹ آؤٹ محفوظ ہو گئی: Rs. $amount')),
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