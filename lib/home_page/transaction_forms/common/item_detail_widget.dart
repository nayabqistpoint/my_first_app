import 'package:flutter/material.dart';

// درست امپورٹ پاتھ: کیونکہ کنٹرولر ذیلی فولڈر 'item_detail_widgets' کے اندر ہے
import 'item_detail_widgets/item_detail_controller.dart';
import 'item_detail_widgets/action_buttons.dart';
import 'item_detail_widgets/condition_selector.dart';
import 'item_detail_widgets/manual_boxes.dart';

class ItemDetailWidget extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const ItemDetailWidget({super.key, this.initialData});

  @override
  State<ItemDetailWidget> createState() => _ItemDetailWidgetState();
}

class _ItemDetailWidgetState extends State<ItemDetailWidget> {
  final ItemDetailController controller = ItemDetailController();

  @override
  void initState() {
    super.initState();
    controller.initWithData(widget.initialData);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // 1. صرف محفوظ کر کے بند کرنا
  void _saveAndClose() {
    final data = controller.buildResultData();
    data['isSaveAndNew'] = false; // فلیگ: بند کرو
    Navigator.pop(context, data);
  }

  // 2. محفوظ کرنا اور Purchase Page کو کہنا کہ نیا فارم بھی کھولو
  void _saveAndNew() {
    final data = controller.buildResultData();
    data['isSaveAndNew'] = true; // فلیگ: ڈیٹا ایڈ کرو اور فارم دوبارہ کھولو
    Navigator.pop(context, data);
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
                      ConditionSelectorWidget(
                        selectedCondition: controller.selectedCondition,
                        onConditionChanged: (val) => setState(() => controller.selectedCondition = val),
                        nameController: controller.nameController,
                        imeiController: controller.imeiController,
                        colorController: controller.colorController,
                        selectedColor: controller.selectedColor,
                        onColorChanged: (val) => setState(() => controller.selectedColor = val),
                        selectedWarrantyMonths: controller.selectedWarrantyMonths,
                        onWarrantyChanged: (val) => setState(() => controller.selectedWarrantyMonths = val ?? 0),
                        
                        // --- RAM اور ROM کے فیلڈز شامل کر دیے گئے ہیں ---
                        ramController: controller.ramController,
                        romController: controller.romController,
                        selectedRam: controller.selectedRam,
                        selectedRom: controller.selectedRom,
                        onRamChanged: (val) => setState(() => controller.selectedRam = val),
                        onRomChanged: (val) => setState(() => controller.selectedRom = val),
                      ),
                      const SizedBox(height: 16),
                      ManualBoxesWidget(
                        purchasePriceController: controller.purchasePriceController,
                        quantityController: controller.quantityController,
                        salePriceController: controller.salePriceController,
                        adjustmentController: controller.adjustmentController,
                        supplierController: controller.supplierController,
                        isPercentageMode: controller.isPercentageMode,
                        onModeChanged: (val) => setState(() => controller.isPercentageMode = val),
                        onPriceAdjust: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ActionButtonsWidget(
                onSaveAndClose: _saveAndClose,
                onSaveAndNew: _saveAndNew, // <-- اب یہ الگ فنکشن کال کر رہا ہے
              ),
            ],
          ),
        ),
      ),
    );
  }
}