import 'package:flutter/material.dart';

import 'item_detail_widgets/action_buttons.dart';
import 'item_detail_widgets/condition_selector.dart';
import 'item_detail_widgets/manual_boxes.dart';

class ItemDetailWidget extends StatefulWidget {
  const ItemDetailWidget({super.key});

  @override
  State<ItemDetailWidget> createState() => _ItemDetailWidgetState();
}

class _ItemDetailWidgetState extends State<ItemDetailWidget> {
  // تمام فیلڈز کے کنٹرولرز
  final TextEditingController nameController = TextEditingController();
  final TextEditingController imeiController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(text: '1');
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();

  String selectedCondition = 'new';
  int selectedWarrantyMonths = 0;
  String? selectedColor;
  bool isPercentageMode = false; // فالس کا مطلب روپیہ موڈ، ٹرو کا مطلب پرسنٹیج موڈ

  @override
  void dispose() {
    nameController.dispose();
    imeiController.dispose();
    colorController.dispose();
    purchasePriceController.dispose();
    quantityController.dispose();
    salePriceController.dispose();
    supplierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        centerTitle: true,
        title: const Text(
          'آئٹم کی تفصیل درج کریں',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ماڈل، کلر اور وارنٹی والا وجٹ
                      ConditionSelectorWidget(
                        selectedCondition: selectedCondition,
                        onConditionChanged: (val) {
                          setState(() {
                            selectedCondition = val;
                          });
                        },
                        nameController: nameController,
                        imeiController: imeiController,
                        colorController: colorController,
                        selectedColor: selectedColor,
                        onColorChanged: (val) {
                          setState(() {
                            selectedColor = val;
                          });
                        },
                        selectedWarrantyMonths: selectedWarrantyMonths,
                        onWarrantyChanged: (val) {
                          setState(() {
                            selectedWarrantyMonths = val ?? 0;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // قیمت خرید، مقدار، قیمت فروخت (بٹنوں کے ساتھ) اور سپلائر والا وجٹ
                      ManualBoxesWidget(
                        purchasePriceController: purchasePriceController,
                        quantityController: quantityController,
                        salePriceController: salePriceController,
                        supplierController: supplierController,
                        isPercentageMode: isPercentageMode,
                        onModeChanged: (val) {
                          setState(() {
                            isPercentageMode = val;
                          });
                        },
                        onPriceAdjust: (newPrice) {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // نیچے والے ایکشن بٹنز
              ActionButtonsWidget(
                onSaveAndClose: () {
                  Navigator.pop(context);
                },
                onSaveAndNew: () {
                  debugPrint('محفوظ اور نئی آئٹم کا بٹن دبایا گیا');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}