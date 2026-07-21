import 'package:flutter/material.dart';
import '../../dashboard/controller.dart';

class SalePurchaseController extends ChangeNotifier {
  int selectedMode = 0;
  
  final TextEditingController partyNameController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  
  final TextEditingController dateController = TextEditingController(
    text: "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
  );

  List<Map<String, TextEditingController>> itemsList = [
    {
      'model': TextEditingController(),
      'imei': TextEditingController(),
      'color': TextEditingController(),
      'qty': TextEditingController(text: '1'),
      'purchasePrice': TextEditingController(),
      'salePrice': TextEditingController(),
    }
  ];

  final TextEditingController discountController = TextEditingController();

  double grandTotal = 0;
  double finalPayableAmount = 0;

  String? selectedBankSource;
  double cashAmount = 0;
  double bankAmount = 0;
  double remainingBalance = 0;

  SalePurchaseController() {
    discountController.addListener(_calculateTotals);
    _attachItemListeners();
  }

  void _attachItemListeners() {
    for (var item in itemsList) {
      item['qty']?.addListener(_calculateTotals);
      item['purchasePrice']?.addListener(_calculateTotals);
    }
  }

  void setMode(int mode) {
    selectedMode = mode;
    notifyListeners();
  }

  void addItemRow() {
    itemsList.add({
      'model': TextEditingController(),
      'imei': TextEditingController(),
      'color': TextEditingController(),
      'qty': TextEditingController(text: '1'),
      'purchasePrice': TextEditingController(),
      'salePrice': TextEditingController(),
    });
    _attachItemListeners();
    _calculateTotals();
  }

  void removeItemRow(int index) {
    if (itemsList.length > 1) {
      itemsList[index]['model']?.dispose();
      itemsList[index]['imei']?.dispose();
      itemsList[index]['color']?.dispose();
      itemsList[index]['qty']?.dispose();
      itemsList[index]['purchasePrice']?.dispose();
      itemsList[index]['salePrice']?.dispose();
      
      itemsList.removeAt(index);
      _calculateTotals();
    }
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      dateController.text = "${picked.day}-${picked.month}-${picked.year}";
      notifyListeners();
    }
  }

  void _calculateTotals() {
    double total = 0;
    for (var item in itemsList) {
      double qty = double.tryParse(item['qty']?.text ?? '0') ?? 0;
      double price = double.tryParse(item['purchasePrice']?.text ?? '0') ?? 0;
      total += (qty * price);
    }

    grandTotal = total;
    double discount = double.tryParse(discountController.text) ?? 0;
    double finalAmount = grandTotal - discount;
    finalPayableAmount = finalAmount < 0 ? 0 : finalAmount;

    remainingBalance = finalPayableAmount - (cashAmount + bankAmount);
    if (remainingBalance < 0) remainingBalance = 0;

    notifyListeners();
  }

  void setSplitPayment(String? bankSource, double cashAmt, double bankAmt) {
    selectedBankSource = bankSource;
    cashAmount = cashAmt;
    bankAmount = bankAmt;
    _calculateTotals();
  }

  void saveData(BuildContext context) {
    // 1. پارٹی کے نام کی ویلیڈیشن
    if (partyNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('براہ کرم پارٹی کا نام درج کریں!'), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. بینک سلیکشن ویلیڈیشن (اگر بینک رقم دی ہے تو بینک لازمی سلیکٹ ہونا چاہیے)
    if (bankAmount > 0 && (selectedBankSource == null || selectedBankSource!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خراب ان پٹ: براہ کرم بینک کی رقم کٹنے کے لیے پہلے متعلقہ بینک منتخب کریں!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 3. کیش ان ہینڈ بیلنس چیک اور کٹوتی
    if (cashAmount > 0) {
      double currentCash = dashboardController.cashInHand; // فرض کریں ڈیش بورڈ میں cashInHand موجود ہے
      if (currentCash >= cashAmount) {
        dashboardController.cashInHand = currentCash - cashAmount;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('كیش ان ہینڈ میں ناکافی رقم ہے! (موجودہ: Rs $currentCash)'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // 4. بینک بیلنس چیک اور کٹوتی
    if (bankAmount > 0 && selectedBankSource != null) {
      if (dashboardController.bankBalances.containsKey(selectedBankSource)) {
        double currentBankBal = dashboardController.bankBalances[selectedBankSource] ?? 0;
        
        if (currentBankBal >= bankAmount) {
          dashboardController.bankBalances[selectedBankSource!] = currentBankBal - bankAmount;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('منتخب کردہ بینک ($selectedBankSource) میں اتنی رقم موجود نہیں ہے! (موجودہ: Rs $currentBankBal)'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    // ڈیش بورڈ کو ریفریش کرنا تاکہ کیش اور بینک دونوں کے لائیو بیلنس اپ ڈیٹ ہو جائیں
    dashboardController.notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('انوائس محفوظ ہو گئی اور کیش و بینک سے رقم کاٹ دی گئی!'), backgroundColor: Colors.green),
    );

    _resetForm();
  }

  void _resetForm() {
    partyNameController.clear();
    whatsappController.clear();
    discountController.clear();
    cashAmount = 0;
    bankAmount = 0;
    // نوٹ: selectedBankSource کو کلیر نہیں کیا تاکہ آخری یوزڈ بینک سلیکٹڈ رہے
    
    itemsList = [
      {
        'model': TextEditingController(),
        'imei': TextEditingController(),
        'color': TextEditingController(),
        'qty': TextEditingController(text: '1'),
        'purchasePrice': TextEditingController(),
        'salePrice': TextEditingController(),
      }
    ];
    
    _attachItemListeners();
    _calculateTotals();
    notifyListeners();
  }

  @override
  void dispose() {
    partyNameController.dispose();
    whatsappController.dispose();
    dateController.dispose();
    discountController.dispose();
    for (var item in itemsList) {
      item['model']?.dispose();
      item['imei']?.dispose();
      item['color']?.dispose();
      item['qty']?.dispose();
      item['purchasePrice']?.dispose();
      item['salePrice']?.dispose();
    }
    super.dispose();
  }
}

final salePurchaseController = SalePurchaseController();