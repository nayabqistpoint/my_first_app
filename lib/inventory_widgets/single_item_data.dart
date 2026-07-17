import 'package:flutter/material.dart';

class SingleItemData {
  final String id;
  final String billId;          // پیرنٹ بل آئی ڈی
  final String model;
  final String category;
  final int purchasePrice;
  final int quantity;           // تعداد
  final String imei;            // اس مخصوص موبائل کا IMEI
  final String supplier;
  final String date;

  SingleItemData({
    required this.id,
    required this.billId,
    required this.model,
    required this.category,
    required this.purchasePrice,
    required this.quantity,
    required this.imei,
    required this.supplier,
    required this.date,
  });
}

// سپلائر کا ڈیٹا جو ہوم پیج پر سنک ہوگا
class SupplierProfile {
  final String name;
  final String phone;
  final int balance; // پلس کا مطلب ہم نے لینے ہیں، مائنس کا مطلب ہم نے دینے ہیں

  SupplierProfile({
    required this.name,
    required this.phone,
    this.balance = 0,
  });
}

// === تفصیلی پاپ اپ وزٹ (Bottom Sheet) ===
class ItemDetailBottomSheet extends StatelessWidget {
  final String modelName;
  final double price;
  final List<SingleItemData> items;

  const ItemDetailBottomSheet({
    super.key,
    required this.modelName,
    required this.price,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ہینڈل بار
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300], 
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // ہیڈر معلومات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rs. ${price.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E3A8A)),
              ),
              Text(
                modelName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          Text(
            'کل دستیاب سٹاک: ${items.length} سیٹ',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.right,
          ),
          const Divider(height: 24),

          // سنگل آئٹمز کی تفصیلی لسٹ
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4, // زیادہ اسٹاک ہونے پر اسکرول ہوگا
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final singleItem = items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'بل نمبر: ${singleItem.billId}',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                          ),
                          Text(
                            'سپلائر: ${singleItem.supplier}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            singleItem.date,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                          ),
                          if (singleItem.imei.isNotEmpty)
                            Text(
                              'IMEI: ${singleItem.imei}',
                              style: const TextStyle(
                                fontSize: 13, 
                                fontFamily: 'monospace', 
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey
                              ),
                            )
                          else
                            const Text(
                              'IMEI درج نہیں ہے',
                              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}