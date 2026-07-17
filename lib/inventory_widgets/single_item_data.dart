import 'package:flutter/material.dart';

// سنگل آئٹم کا ڈیٹا ماڈل
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

  // مخصوص انوائس کی تفصیلی رسید دکھانے کا فنکشن
  void _showInvoiceReceipt(BuildContext context, String invoiceNo, String supplierName) {
    // یہاں ہم ان تمام آئٹمز کو فلٹر کر رہے ہیں جن کا بل نمبر اس کلک کردہ بل نمبر سے میچ کرتا ہے
    final invoiceItems = items.where((element) => element.billId == invoiceNo).toList();
    
    double totalBillAmount = 0;
    for (var item in invoiceItems) {
      totalBillAmount += (item.quantity * item.purchasePrice);
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Container(
            padding: const EdgeInsets.only(bottom: 12),
            // یہاں بارڈر کو BoxDecoration کے اندر شفٹ کر دیا ہے تاکہ ایرر ختم ہو جائے
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.receipt_long, color: Color(0xFF1E3A8A)),
                Text(
                  'اصل بل نمبر: $invoiceNo',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A)),
                ),
              ],
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // سپلائر کا نام
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      supplierName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                    ),
                    const Text(
                      'سپلائر کا نام:',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // کالم ہیڈرز
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  color: Colors.grey.shade100,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('کل قیمت', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      Text('ریٹ × تعداد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      Text('آئٹم/ماڈل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // انوائس کے اندر موجود تمام موبائلز کی لسٹ
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: invoiceItems.length,
                    itemBuilder: (context, idx) {
                      final invItem = invoiceItems[idx];
                      final itemTotal = invItem.quantity * invItem.purchasePrice;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Rs. $itemTotal', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            Text('${invItem.quantity} × Rs. ${invItem.purchasePrice}', style: const TextStyle(fontSize: 12)),
                            Expanded(
                              child: Text(
                                invItem.model,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 24),

                // ٹوٹل بل
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs. ${totalBillAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
                    ),
                    const Text(
                      'کل بل کی مالیت:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('بند کریں', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

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
                        // سپلائر اور ریٹ فارمیٹنگ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
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
                        const SizedBox(height: 10),

                        // IMEI اور انوائس ہائپر لنک
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // بل نمبر ہائپر لنک
                            InkWell(
                              onTap: () {
                                _showInvoiceReceipt(context, item.billId, item.supplier);
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Row(
                                  children: [
                                    const Icon(Icons.link, size: 14, color: Colors.blue),
                                    const SizedBox(width: 2),
                                    Text(
                                      'بل نمبر: ${item.billId}',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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