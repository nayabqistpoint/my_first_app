import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_first_app/dashboard/widgets/payment_source_card.dart';
import 'package:my_first_app/home_page/transaction_forms/common/discount_widget.dart';

class PaymentOutController {
  final TextEditingController amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  final ValueNotifier<bool> hasAmountEntered = ValueNotifier<bool>(false);
  final ValueNotifier<double> currentAmountNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> isSaving = ValueNotifier<bool>(false);

  final GlobalKey<PaymentSourceCardState> sourceCardKey = GlobalKey<PaymentSourceCardState>();

  String? audioPath;
  double _discountValue = 0.0;
  bool _isPercentageDiscount = false;
  String _selectedDiscountCategory = 'Discounts';
  String? _selectedSource = 'Cash';

  String? get selectedPaymentSource => _selectedSource;

  void updateSelectedSource(String? newSource) => _selectedSource = newSource;

  PaymentOutController() {
    amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    final text = amountController.text.trim();
    currentAmountNotifier.value = double.tryParse(text) ?? 0.0;
    hasAmountEntered.value = text.isNotEmpty;
  }

  void updateDiscount(String categoryName, double value, bool isPercentage) {
    _selectedDiscountCategory = categoryName;
    _discountValue = value;
    _isPercentageDiscount = isPercentage;
  }

  void dispose() {
    amountController.dispose();
    amountFocusNode.dispose();
    hasAmountEntered.dispose();
    currentAmountNotifier.dispose();
    isSaving.dispose();
  }

  Future<void> savePaymentOut(BuildContext context, {String? customerId, bool isExpense = false}) async {
    if (isSaving.value) return;

    final String amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('براہ کرم رقم درج کریں')),
      );
      return;
    }

    isSaving.value = true;
    final double amount = double.tryParse(amountText) ?? 0.0;

    // ڈسکاؤنٹ اور بقایا رقم کا حساب
    final double calculatedDiscountAmount = _isPercentageDiscount ? (amount * _discountValue) / 100 : _discountValue;
    final double netAmountToDeduct = (amount - calculatedDiscountAmount).clamp(0.0, double.infinity);

    // PaymentSourceCard سے ڈیٹا کی وصولی
    List<Map<String, dynamic>> splitPayments = [];
    String? picturePath;
    String description = '';

    final state = sourceCardKey.currentState;
    if (state != null) {
      splitPayments = state.getSplitPaymentsList();
      picturePath = state.attachedImagePath;
      description = state.noteController.text.trim();
    }

    final bool hasPicture = picturePath != null && picturePath.isNotEmpty;
    final bool hasAudio = audioPath != null && audioPath!.isNotEmpty;
    final String cleanPhone = (customerId ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final String nowIso = DateTime.now().toIso8601String();

    final Map<String, dynamic> transactionData = {
      'type': 'paid',
      'customerPhone': cleanPhone,
      'customerId': cleanPhone,
      'amount': amount,
      'netAmount': netAmountToDeduct,
      'description': description,
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
      'hasPicture': hasPicture,
      'picturePath': hasPicture ? picturePath : null,
      'hasAudio': hasAudio,
      'audioPath': hasAudio ? audioPath : null,
      'timestamp': nowIso,
    };

    try {
      // ۱۔ ٹرانزیکشن اور ایکسپینس باکس میں سیو
      await Hive.box('transactionBox').add(transactionData);
      if (isExpense) {
        await Hive.box('expenseBox').add(transactionData);
      }

      // ۲۔ بینک/کیش باکس اپڈیٹ
      var bankBox = Hive.box('bankBox');
      if (splitPayments.isNotEmpty) {
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
        String sourceKey = _selectedSource ?? 'Cash';
        double currentBalance = (bankBox.get(sourceKey, defaultValue: 0.0) as num).toDouble();
        await bankBox.put(sourceKey, currentBalance - netAmountToDeduct);
      }

      // ۳۔ ڈسکاؤنٹ ریکارڈنگ
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
          SnackBar(content: Text('خرابی پیش آئی: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (context.mounted) isSaving.value = false;
    }
  }
}