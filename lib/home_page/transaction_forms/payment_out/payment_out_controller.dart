import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../dashboard/widgets/payment_source_card.dart';
import '../common/discount_widget.dart';

class PaymentOutController {
  final TextEditingController amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  final ValueNotifier<bool> hasAmountEntered = ValueNotifier<bool>(false);
  final ValueNotifier<double> currentAmountNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> isSaving = ValueNotifier<bool>(false);

  // GlobalKey for PaymentSourceCard State
  final GlobalKey<PaymentSourceCardState> sourceCardKey = GlobalKey<PaymentSourceCardState>();

  String? audioPath;

  double _discountValue = 0.0;
  bool _isPercentageDiscount = false;
  String _selectedDiscountCategory = 'Discounts';
  
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

  // پیمنٹ آؤٹ سیو کرنے کا اپڈیٹ شدہ اور آپٹمائزڈ فنکشن
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

    // ۱۔ ڈسکاؤنٹ کی رقم کا حساب لگانا
    double calculatedDiscountAmount = 0.0;
    if (_isPercentageDiscount) {
      calculatedDiscountAmount = (amount * _discountValue) / 100;
    } else {
      calculatedDiscountAmount = _discountValue;
    }

    // ۲۔ کیش یا بینک سے منہا ہونے والی اصل بقایا رقم
    double netAmountToDeduct = amount - calculatedDiscountAmount;
    if (netAmountToDeduct < 0) netAmountToDeduct = 0.0;

    // PaymentSourceCard سے تصویر، ڈسکرپشن اور اسپلٹ لسٹ حاصل کرنا (ناموں کو فکس کر دیا گیا ہے)
    List<Map<String, dynamic>> splitPayments = [];
    String? picturePath;
    String description = '';

    final state = sourceCardKey.currentState;
    if (state != null) {
      splitPayments = state.getSplitPaymentsList();
      picturePath = state.attachedImagePath; // 'imagePath' کے بجائے 'attachedImagePath'
      description = state.noteController.text.trim(); // 'descriptionController' کے بجائے 'noteController'
    }

    bool hasPicture = picturePath != null && picturePath.isNotEmpty;
    bool hasAudio = audioPath != null && audioPath!.isNotEmpty;

    String cleanPhone = (customerId ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final String nowIso = DateTime.now().toIso8601String();

    // اپڈیٹ شدہ اور کلین ڈیٹا ماڈل (کوئی remarks فیلڈ نہیں)
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
      // ۱۔ ٹرانزیکشن باکس میں سیو کرنا
      var txnBox = Hive.box('transactionBox');
      await txnBox.add(transactionData);

      // ۲۔ اگر یہ دکان کا خرچہ ہے تو اخراجات باکس میں بھی سیو کریں
      if (isExpense) {
        var expenseBox = Hive.box('expenseBox');
        await expenseBox.add(transactionData);
      }

      // ۳۔ bankBox سے رقم منہا (Deduct) کرنا
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

      // ۴۔ ڈسکاؤنٹ کی رقم کو 'expenseBox' کی کیٹیگری میں ریکارڈ کرنا
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