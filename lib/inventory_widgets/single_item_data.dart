import 'package:flutter/material.dart';

// ماڈل کلاس جو سنگل آئٹم کا ڈیٹا ہینڈل کرے گی
class SingleItemData {
  final String id;
  final String billId;
  final String model;
  final String category;
  final int purchasePrice;
  final int quantity;
  final String imei;
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

// باٹم پاپ اپ شیٹ جو تفصیلات دکھائے گی
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ہینڈل بار
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // ہیڈر
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'اوسط قیمت: Rs. ${price.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 13),
              ),
              Text(
                modelName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
            ],
          ),
          const Divider(height: 24),

          // تفصیلات کی لسٹ
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final double totalItemCost = (item.quantity * item.purchasePrice).toDouble();

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: Colors.grey.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // سپلائر اور بل نمبر کا سیکشن
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              // پاپ اپ کے اندر قیمت کی فارمیٹنگ
                              child: Text(
                                '${item.quantity} سیٹ × Rs. ${item.purchasePrice} = Rs. ${totalItemCost.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Text(
                              item.supplier,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // IMEI اور بل کی معلومات
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'بل نمبر: ${item.billId}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                            Text(
                              'IMEI: ${item.imei}',
                              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
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