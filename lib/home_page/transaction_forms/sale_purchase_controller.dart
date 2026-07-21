import 'package:flutter/material.dart';

class SalePurchaseController extends ChangeNotifier {
  int selectedMode = 0;
  
  final TextEditingController partyNameController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  
  final TextEditingController dateController = TextEditingController(
    text: "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
  );

  final List<Map<String, TextEditingController>> itemsList = [
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

  double cashAmount = 0;
  String? selectedBank;
  double bankAmount = 0;

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

    notifyListeners();
  }

  void setSplitPayment(String? bank, double cash, double bankAmt) {
    selectedBank = bank;
    cashAmount = cash;
    bankAmount = bankAmt;
    notifyListeners();
  }

  void saveData() {
    debugPrint("ڈیٹا محفوظ ہو رہا ہے... فائنل اماؤنٹ: $finalPayableAmount");
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