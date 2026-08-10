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

  // --- RAM اور ROM کے لیے کنٹرولرز ---
  final TextEditingController ramController = TextEditingController();
  final TextEditingController romController = TextEditingController();

  String selectedCondition = 'new';
  int selectedWarrantyMonths = 0;
  String? selectedColor;
  
  // --- RAM اور ROM کی منتخب ویلیوز ---
  String? selectedRam;
  String? selectedRom;

  bool isPercentageMode = false;

  final List<Map<String, dynamic>> addedItems = [];

  // ایڈٹ کرتے وقت ایڈجسٹمنٹ اور باقی فیلڈز کو صحیح لوڈ کرنے کی لاجک
  void initWithData(Map<String, dynamic>? data) {
    if (data == null) return;
    nameController.text = data['itemName'] ?? '';
    imeiController.text = data['imeiNo'] ?? '';
    colorController.text = data['color'] ?? '';
    purchasePriceController.text = data['purchasePrice'] ?? '';
    quantityController.text = data['quantity'] ?? '1';
    salePriceController.text = data['salePrice'] ?? '';
    
    // ایڈجسٹمنٹ کو لوڈ کرنا تاکہ ایڈٹ کرتے وقت زیرو نہ ہو
    adjustmentController.text = data['adjustment'] ?? '';
    
    supplierController.text = data['supplier'] ?? '';
    selectedCondition = data['condition'] ?? 'new';
    selectedWarrantyMonths = data['warranty'] ?? 0;
    selectedColor = data['color'];

    // --- RAM اور ROM کو لوڈ کرنا ---
    ramController.text = data['ram'] ?? '';
    romController.text = data['rom'] ?? '';
    selectedRam = data['selectedRam'];
    selectedRom = data['selectedRom'];
  }

  bool saveCurrentAndPrepareNew() {
    if (nameController.text.trim().isEmpty && purchasePriceController.text.trim().isEmpty) {
      return false;
    }

    final currentData = buildResultData();
    addedItems.add(currentData);
    clearFields();
    return true;
  }

  List<Map<String, dynamic>> getFinalResults() {
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

    // --- RAM اور ROM کلیئر کرنا ---
    ramController.clear();
    romController.clear();
    selectedRam = null;
    selectedRom = null;

    selectedCondition = 'new';
    selectedWarrantyMonths = 0;
    selectedColor = null;
    isPercentageMode = false;
  }

  Map<String, dynamic> buildResultData() {
    final double price = double.tryParse(purchasePriceController.text) ?? 0.0;
    final int qty = int.tryParse(quantityController.text) ?? 1;

    // اگر مینوئل لکھا گیا ہو تو وہ لیں ورنہ ڈراپ ڈاؤن کی ویلیو
    final String finalRam = ramController.text.isNotEmpty ? ramController.text : (selectedRam ?? '');
    final String finalRom = romController.text.isNotEmpty ? romController.text : (selectedRom ?? '');

    return {
      "itemName": nameController.text.isEmpty ? "موبائل / آئٹم" : nameController.text,
      "imeiNo": imeiController.text,
      "subTotal": (price * qty).toStringAsFixed(2),
      "calculationText": "$qty × ${price.toStringAsFixed(0)}",
      "purchasePrice": purchasePriceController.text,
      "quantity": quantityController.text,
      "salePrice": salePriceController.text,
      "adjustment": adjustmentController.text, // ایڈجسٹمنٹ محفوظ کی جا رہی ہے
      "supplier": supplierController.text,
      "condition": selectedCondition,
      "warranty": selectedWarrantyMonths,
      "color": selectedColor,

      // --- RAM اور ROM پیکٹ میں محفوظ کرنا ---
      "ram": finalRam,
      "selectedRam": selectedRam,
      "rom": finalRom,
      "selectedRom": selectedRom,
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

    // --- RAM اور ROM کنٹرولرز ڈسپوز کرنا ---
    ramController.dispose();
    romController.dispose();
  }
}