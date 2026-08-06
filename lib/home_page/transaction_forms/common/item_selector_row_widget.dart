import 'package:flutter/material.dart';
import 'item_detail_widget.dart'; // فل پیج کو یہاں امپورٹ کر دیا گیا ہے

class ItemSelectorRowWidget extends StatelessWidget {
  final VoidCallback onAddAnotherItem; // نئی رو یا آئٹم ایڈ کرنے کا فنکشن

  const ItemSelectorRowWidget({
    super.key,
    required this.onAddAnotherItem,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: InkWell(
        // جب بھی اس رو پر کلک ہوگا، یہ فل پیج (ItemDetailWidget) کو کھول دے گا
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ItemDetailWidget()),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.red.shade700, width: 1.0), // ریڈ اینڈ وائٹ کمبینیشن
          ),
          child: Row(
            children: [
              // 1. آئٹم کا نام / سلیکٹر (بائیں طرف)
              const Expanded(
                flex: 3,
                child: Text(
                  'آئٹم منتخب کریں...',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const VerticalDivider(color: Colors.grey, thickness: 0.5),

              // 2. مقدار (Qty)
              const SizedBox(
                width: 40,
                child: Text(
                  '1',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),

              // 3. قیمت (Price)
              const SizedBox(
                width: 60,
                child: Text(
                  '0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),

              // 4. سب ٹوٹل (Subtotal)
              const SizedBox(
                width: 70,
                child: Text(
                  '0',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),

              const SizedBox(width: 8),

              // 5. جگہ بچانے والا سمارٹ پلس (+) بٹن (نئی رو کے لیے)
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add_circle, color: Colors.red, size: 24),
                  tooltip: 'نئی آئٹم شامل کریں',
                  onPressed: onAddAnotherItem,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}