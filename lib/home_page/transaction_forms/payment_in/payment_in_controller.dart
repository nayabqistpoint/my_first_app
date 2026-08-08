import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../dashboard/widgets/payment_source_card.dart';

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

  void updateDiscount(double value, bool isPercentage) {
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
      'description': remarks,
      'remarks': remarks,
      'date': nowIso,
      'discount': {
        'value': _discountValue,
        'isPercentage': _isPercentageDiscount,
      },
      'source': _selectedSource ?? 'Cash',
      'splitPayments': isSplit ? splitList : [],
      'hasAttachment': false,
      'timestamp': nowIso,
    };

    try {
      // ۱. ٹرانزیکشن باکس میں اندراج
      var txnBox = Hive.box('transactionBox');
      await txnBox.add(transactionData);

      // ۲. ڈائریکٹ ہائیو کے 'bankBox' میں لائیو اور ڈائنامک پلس کرنا
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
        // سنگل موڈ: منتخب کردہ مخصوص بینک یا کیش میں پوری رقم جمع کرنا
        String sourceKey = _selectedSource ?? 'Cash';
        double currentBalance = (bankBox.get(sourceKey, defaultValue: 0.0) as num).toDouble();
        await bankBox.put(sourceKey, currentBalance + totalAmount);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('کامیاب! پیمنٹ اِن محفوظ ہو گئی: Rs. $totalAmount'),
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