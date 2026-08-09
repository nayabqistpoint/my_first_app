import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../dashboard/widgets/payment_source_card.dart';
import '../common/discount_widget.dart'; // 🔥 DiscountWidget امپورٹ

class PaymentOutController {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  
  final FocusNode amountFocusNode = FocusNode();

  final ValueNotifier<bool> hasAmountEntered = ValueNotifier<bool>(false);
  final ValueNotifier<double> currentAmountNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> isSaving = ValueNotifier<bool>(false);

  // ڈائنامک سورس کارڈ کا کنٹرول کے لیے GlobalKey
  final GlobalKey<PaymentSourceCardState> sourceCardKey = GlobalKey<PaymentSourceCardState>();

  double _discountValue = 0.0;
  bool _isPercentageDiscount = false;
  String _selectedDiscountCategory = 'Discounts'; // 🔥 منتخب کردہ ڈسکاؤنٹ/انکم کیٹیگری
  
  String? _selectedSource = 'Cash';

  String? get selectedPaymentSource => _selectedSource;

  void updateSelectedSource(String? newSource) {
    _selectedSource = newSource;
  }

  PaymentOutController() {
    amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    final text = amountController.text.trim();
    final parsedAmount = double.tryParse(text) ?? 0.0;
    
    currentAmountNotifier.value = parsedAmount;
    hasAmountEntered.value = text.isNotEmpty;
  }

  // 🔥 3 پیرامیٹرز کے ساتھ اپ ڈیٹ شدہ ڈسکاؤنٹ فنکشن 🔥
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

  // ہائیو باکس (bankBox) سے ڈائنامک رقم منہا (Deduct) کرنے کا اصلی فنکشن
  Future<void> savePaymentOut(BuildContext context, {String? customerId, bool isExpense = false}) async {
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

    // 🔥 ۱۔ ڈسکاؤنٹ کی رقم کا حساب لگانا 🔥
    double calculatedDiscountAmount = 0.0;
    if (_isPercentageDiscount) {
      calculatedDiscountAmount = (amount * _discountValue) / 100;
    } else {
      calculatedDiscountAmount = _discountValue;
    }

    // 🔥 ۲۔ کیش یا بینک سے وضع (Deduct) ہونے والی اصل بقایا رقم 🔥
    double netAmountToDeduct = amount - calculatedDiscountAmount;
    if (netAmountToDeduct < 0) netAmountToDeduct = 0.0;

    // PaymentSourceCard سے لائیو اسپلٹ لسٹ اٹھانا
    List<Map<String, dynamic>> splitPayments = [];
    if (sourceCardKey.currentState != null) {
      splitPayments = sourceCardKey.currentState!.getSplitPaymentsList();
    }

    String cleanPhone = (customerId ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final String nowIso = DateTime.now().toIso8601String();

    final Map<String, dynamic> transactionData = {
      'type': 'paid', 
      'customerPhone': cleanPhone,
      'customerId': cleanPhone, 
      'amount': amount,
      'netAmount': netAmountToDeduct,
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
      'splitPayments': splitPayments,
      'isExpense': isExpense,
      'hasAttachment': false,
      'timestamp': nowIso,
    };

    try {
      // ۱۔ ٹرانزیکشن باکس میں انٹری
      var txnBox = Hive.box('transactionBox');
      await txnBox.add(transactionData);

      // ۲۔ اگر یہ دکان کا خرچہ ہے تو اخراجات باکس میں بھی بھیجیں
      if (isExpense) {
        var expenseBox = Hive.box('expenseBox');
        await expenseBox.add(transactionData);
      }

      // ۳۔ ڈائریکٹ ہائیو (bankBox) سے مائنس ڈسکاؤنٹ شدہ رقم (Net Amount) منہا (Deduct) کرنا
      var bankBox = Hive.box('bankBox');

      if (splitPayments.isNotEmpty) {
        // اسپلٹ موڈ: تمام منتخب سورسز سے الگ الگ کٹوتی
        for (var split in splitPayments) {
          String srcKey = split['source'] ?? 'Cash';
          double splitAmt = (split['amount'] is num)
              ? (split['amount'] as num).toDouble()
              : (double.tryParse(split['amount'].toString()) ?? 0.0);

          if (splitAmt > 0) {
            double currentBalance = (bankBox.get(srcKey, defaultValue: 0.0) as num).toDouble();
            await bankBox.put(srcKey, currentBalance - splitAmt);
          }
        }
      } else {
        // سنگل موڈ: منتخب کردہ بینک یا کیش سے مائنس ڈسکاؤنٹ رقم کی کٹوتی
        String sourceKey = _selectedSource ?? 'Cash';
        double currentBalance = (bankBox.get(sourceKey, defaultValue: 0.0) as num).toDouble();
        await bankBox.put(sourceKey, currentBalance - netAmountToDeduct);
      }

      // 🔥 ۴۔ ڈسکاؤنٹ کی رقم کو 'expenseBox' کی منتخب کردہ کیٹیگری میں ریکارڈ کرنا 🔥
      if (calculatedDiscountAmount > 0) {
        DiscountWidget.recordDiscountInHive(
          categoryName: _selectedDiscountCategory,
          amount: calculatedDiscountAmount,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('کامیاب! پیمنٹ آؤٹ محفوظ ہو گئی: Rs. ${netAmountToDeduct.toStringAsFixed(0)}'),
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