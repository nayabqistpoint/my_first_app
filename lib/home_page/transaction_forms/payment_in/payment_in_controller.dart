import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../dashboard/widgets/payment_source_card.dart';
import '../common/discount_widget.dart';

class PaymentInController {
  final TextEditingController amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  final ValueNotifier<bool> hasAmountEntered = ValueNotifier<bool>(false);
  final ValueNotifier<double> currentAmountNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> isSaving = ValueNotifier<bool>(false);

  // PaymentSourceCard کے ساتھ رابطہ قائم کرنے والی GlobalKey
  final GlobalKey<PaymentSourceCardState> paymentSourceCardKey = GlobalKey<PaymentSourceCardState>();

  // آڈیو پاتھ کو کنٹرول کرنے کا ویری ایبل
  String? audioPath;

  double _discountValue = 0.0;
  bool _isPercentageDiscount = false;
  String _selectedDiscountCategory = 'Discounts';
  
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

    try {
      double totalAmount = double.tryParse(amountText) ?? 0.0;

      // ۱۔ ڈسکاؤنٹ کا حساب
      double calculatedDiscountAmount = 0.0;
      if (_isPercentageDiscount) {
        calculatedDiscountAmount = (totalAmount * _discountValue) / 100;
      } else {
        calculatedDiscountAmount = _discountValue;
      }

      // ۲۔ اصل رقم (Net Amount)
      double netAmountToReceive = totalAmount - calculatedDiscountAmount;
      if (netAmountToReceive < 0) netAmountToReceive = 0.0;

      String cleanPhone = (customerId ?? '').replaceAll(RegExp(r'[^0-9]'), '');
      final String nowIso = DateTime.now().toIso8601String();

      // ۳۔ لائیو PaymentSourceCard سے تصویر اور نوٹ کا ڈیٹا حاصل کرنا
      final cardState = paymentSourceCardKey.currentState;
      bool isSplit = cardState?.isSplitMode ?? false;
      List<Map<String, dynamic>> splitList = cardState?.getSplitPaymentsList() ?? [];

      // PaymentSourceCard سے ڈسکرپشن نکالنا
      String cardDescription = cardState?.noteController.text.trim() ?? '';
      
      // PaymentSourceCard کی اسٹیٹ سے منسلک تصویر کا پاتھ حاصل کرنا
      String? picturePath = cardState?.attachedImagePath;
      bool hasPicture = picturePath != null && picturePath.trim().isNotEmpty;

      // آڈیو پاتھ کی جانچ
      bool hasAudio = audioPath != null && audioPath!.trim().isNotEmpty;

      // ٹرانزیکشن کا حقیقی ماڈل
      final Map<String, dynamic> transactionData = {
        'type': 'received', 
        'customerPhone': cleanPhone,
        'customerId': cleanPhone, 
        'amount': totalAmount,
        'netAmount': netAmountToReceive,
        'description': cardDescription,
        'date': nowIso,
        'discount': {
          'category': _selectedDiscountCategory,
          'value': _discountValue,
          'amount': calculatedDiscountAmount,
          'isPercentage': _isPercentageDiscount,
        },
        'source': _selectedSource ?? 'Cash',
        'splitPayments': isSplit ? splitList : [],
        'hasPicture': hasPicture,
        'picturePath': hasPicture ? picturePath : null,
        'hasAudio': hasAudio,
        'audioPath': hasAudio ? audioPath : null,
        'timestamp': nowIso,
      };

      // ہائیو کے TransactionBox میں ڈیٹا محفوظ کرنا
      var txnBox = Hive.box('transactionBox');
      await txnBox.add(transactionData);

      // BankBox میں لیجر اپڈیٹ کرنا
      var bankBox = Hive.box('bankBox');

      if (isSplit && splitList.isNotEmpty) {
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
        String sourceKey = _selectedSource ?? 'Cash';
        double currentBalance = (bankBox.get(sourceKey, defaultValue: 0.0) as num).toDouble();
        await bankBox.put(sourceKey, currentBalance + netAmountToReceive);
      }

      // ExpenseBox میں ڈسکاؤنٹ کی اینٹری
      if (calculatedDiscountAmount > 0) {
        try {
          DiscountWidget.recordDiscountInHive(
            categoryName: _selectedDiscountCategory,
            amount: calculatedDiscountAmount,
          );
        } catch (e) {
          debugPrint('Discount recording error: $e');
        }
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
      debugPrint('Save Payment Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خرابی پیش آئی: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      isSaving.value = false;
    }
  }
}