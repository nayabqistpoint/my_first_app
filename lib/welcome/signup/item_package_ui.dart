// فائل کا نام: item_package_ui.dart
import 'package:flutter/material.dart';
import 'item_package_logic.dart'; // لاجک فائل کو امپورٹ کیا

class ItemPackageUI extends StatefulWidget {
  const ItemPackageUI({super.key});

  @override
  State<ItemPackageUI> createState() => ItemPackageUIState();
}

class ItemPackageUIState extends State<ItemPackageUI> {
  // لاجک کلاس کا آبجیکٹ بنا لیا تاکہ سارا بوجھ ادھر رہے
  final ItemPackageLogic _logic = ItemPackageLogic();

  // پیرنٹ (سائن اپ پیج) کو ڈیٹا دینے کے لیے فنکشن
  Map<String, dynamic> getPackageData() {
    return _logic.getPackageData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Text(
          '3. آئٹم اور پیکج کی معلومات\n(یہاں قسط کیلکولیٹر کا خوبصورت کارڈ بنے گا)',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}