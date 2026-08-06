import 'package:flutter/material.dart';

class ItemDetailController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController imeiController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(text: '1');
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController adjustmentController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();

  String selectedCondition = 'new';
  int selectedWarrantyMonths = 0;
  String? selectedColor;
  bool isPercentageMode = false;

  // سمارٹ فہرست: جو 'محفوظ اور نئی' والے تمام آئٹمز اپنے پاس سٹور رکھے گی
  final List<Map<String, dynamic>> addedItems = [];

  void initWithData(Map<String, dynamic>? data) {
    if (data == null) return;
    nameController.text = data['itemName'] ?? '';
    imeiController.text = data['imeiNo'] ?? '';
    colorController.text = data['color'] ?? '';
    purchasePriceController.text = data['purchasePrice'] ?? '';
    quantityController.text = data['quantity'] ?? '1';
    salePriceController.text = data['salePrice'] ?? '';
    adjustmentController.text = data['adjustment'] ?? '';
    supplierController.text = data['supplier'] ?? '';
    selectedCondition = data['condition'] ?? 'new';
    selectedWarrantyMonths = data['warranty'] ?? 0;
    selectedColor = data['color'];
  }

  // موجودہ اینٹری کو لسٹ میں محفوظ کر کے اگلی اینٹری کے لیے فارم کو ری سیٹ کرنا
  bool saveCurrentAndPrepareNew() {
    // چیک کریں کہ کم از کم آئٹم کا نام یا قیمت موجود ہو
    if (nameController.text.trim().isEmpty && purchasePriceController.text.trim().isEmpty) {
      return false; // اینٹری خالی تھی
    }

    final currentData = buildResultData();
    addedItems.add(currentData); // سمارٹ لسٹ میں شامل کر دیا
    clearFields(); // فارم خالی کر دیا
    return true;
  }

  // فائنل لسٹ تیار کرنا (چاہے 1 آئٹم ہو یا 10 آئٹمز)
  List<Map<String, dynamic>> getFinalResults() {
    // اگر کرنٹ فارم میں بھی کچھ لکھا ہوا ہے اور بند کیا جا رہا ہے، تو اسے بھی شامل کر لیں
    if (nameController.text.trim().isNotEmpty || purchasePriceController.text.trim().isNotEmpty) {
      addedItems.add(buildResultData());
    }
    return addedItems;
  }

  void clearFields() {
    nameController.clear();
    imeiController.clear();
    colorController.clear();
    purchasePriceController.clear();
    quantityController.text = '1';
    salePriceController.clear();
    adjustmentController.clear();
    supplierController.clear();
    selectedCondition = 'new';
    selectedWarrantyMonths = 0;
    selectedColor = null;
    isPercentageMode = false;
  }

  Map<String, dynamic> buildResultData() {
    final double price = double.tryParse(purchasePriceController.text) ?? 0.0;
    final int qty = int.tryParse(quantityController.text) ?? 1;

    return {
      "itemName": nameController.text.isEmpty ? "موبائل / آئٹم" : nameController.text,
      "imeiNo": imeiController.text,
      "subTotal": (price * qty).toStringAsFixed(2),
      "calculationText": "$qty × ${price.toStringAsFixed(0)}",
      "purchasePrice": purchasePriceController.text,
      "quantity": quantityController.text,
      "salePrice": salePriceController.text,
      "adjustment": adjustmentController.text,
      "supplier": supplierController.text,
      "condition": selectedCondition,
      "warranty": selectedWarrantyMonths,
      "color": selectedColor,
    };
  }

  void dispose() {
    nameController.dispose();
    imeiController.dispose();
    colorController.dispose();
    purchasePriceController.dispose();
    quantityController.dispose();
    salePriceController.dispose();
    adjustmentController.dispose();
    supplierController.dispose();
  }
}