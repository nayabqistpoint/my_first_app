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

  final GlobalKey<PaymentSourceCardState> paymentSourceCardKey = GlobalKey<PaymentSourceCardState>();

  String? audioPath;
  double _discountValue = 0.0;
  bool _isPercentageDiscount = false;
  String _selectedDiscountCategory = 'Discounts';
  String? _selectedSource = 'Cash';

  String? get selectedPaymentSource => _selectedSource;

  void updateSelectedSource(String? newSource) => _selectedSource = newSource;

  PaymentInController() {
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

  Future<void> savePaymentIn(BuildContext context, {String? customerId}) async {
    if (isSaving.value) return;

    final String amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('براہ کرم رقم درج کریں')),
      );
      return;
    }

    isSaving.value = true;

    try {
      final double totalAmount = double.tryParse(amountText) ?? 0.0;

      // ۱۔ ڈسکاؤنٹ اور نٹ اماؤنٹ کا حساب
      final double calculatedDiscount = _isPercentageDiscount
          ? (totalAmount * _discountValue) / 100
          : _discountValue;

      final double netAmountToReceive = (totalAmount - calculatedDiscount).clamp(0.0, double.infinity);
      final String cleanPhone = (customerId ?? '').replaceAll(RegExp(r'[^0-9]'), '');
      final String nowIso = DateTime.now().toIso8601String();

      // ۲۔ PaymentSourceCard سے تصویر اور نوٹ ریسیو کرنا
      final cardState = paymentSourceCardKey.currentState;
      final bool isSplit = cardState?.isSplitMode ?? false;
      final List<Map<String, dynamic>> splitList = cardState?.getSplitPaymentsList() ?? [];
      final String cardDescription = cardState?.noteController.text.trim() ?? '';

      final String? picturePath = cardState?.attachedImagePath;
      final bool hasPicture = picturePath != null && picturePath.trim().isNotEmpty;
      final bool hasAudio = audioPath != null && audioPath!.trim().isNotEmpty;

      // ۳۔ ٹرانزیکشن کا ڈیٹا ابجیکٹ
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
          'amount': calculatedDiscount,
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

      // ۴۔ ڈیٹا بیس (Hive) میں ڈیٹا محفوظ کرنا
      await Hive.box('transactionBox').add(transactionData);

      // ۵۔ BankBox اپڈیٹ
      final  bankBox = Hive.box('bankBox');
      if (isSplit && splitList.isNotEmpty) {
        for (var split in splitList) {
          final String srcKey = split['source'] ?? 'Cash';
          final double splitAmt = (split['amount'] is num)
              ? (split['amount'] as num).toDouble()
              : (double.tryParse(split['amount'].toString()) ?? 0.0);

          if (splitAmt > 0) {
            final double currBal = (bankBox.get(srcKey, defaultValue: 0.0) as num).toDouble();
            await bankBox.put(srcKey, currBal + splitAmt);
          }
        }
      } else {
        final String sourceKey = _selectedSource ?? 'Cash';
        final double currBal = (bankBox.get(sourceKey, defaultValue: 0.0) as num).toDouble();
        await bankBox.put(sourceKey, currBal + netAmountToReceive);
      }

      // ۶۔ ExpenseBox ڈسکاؤنٹ ہینڈلنگ
      if (calculatedDiscount > 0) {
        try {
          DiscountWidget.recordDiscountInHive(
            categoryName: _selectedDiscountCategory,
            amount: calculatedDiscount,
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