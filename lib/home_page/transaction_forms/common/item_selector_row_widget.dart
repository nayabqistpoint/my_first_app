import 'package:flutter/material.dart';
import 'item_detail_widget.dart';

class ItemSelectorRowWidget extends StatelessWidget {
  final bool hasItems;
  final String? itemName;
  final int? totalQty;
  final double? unitPrice;
  final double? subTotal;
  final String? description;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onPlusTap;

  const ItemSelectorRowWidget({
    super.key,
    required this.hasItems,
    this.itemName,
    this.totalQty,
    this.unitPrice,
    this.subTotal,
    this.description,
    this.onTap,
    this.onEditTap,
    this.onDeleteTap,
    this.onPlusTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasItems) {
      // جب کوئی آئٹم شامل نہ ہو (شروع کی حالت)
      return InkWell(
        onTap: onTap ?? () {
          // براہ راست یہیں سے آئٹم ڈیٹیل پیج یا پاپ اپ کھولیں
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailWidget(
                initialModel: '',
                initialQty: 1,
                initialPurchasePrice: 0.0,
                initialSalePrice: 0.0,
                initialDescription: '',
                initialImei: '',
                initialCategory: 'موبائل فون (Mobile Phone)',
                onItemSaved: (model, qty, purchasePrice, salePrice, desc, imei, category) {
                  // یہاں ڈیٹا سیو ہونے کا پروسیس آئے گا
                },
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_circle_outline, color: Color(0xFFE53935), size: 20),
              SizedBox(width: 8),
              Text(
                'آئٹم شامل کریں (Item Add करें)',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // جب آئٹم لسٹ میں موجود ہو
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    itemName ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (onEditTap != null)
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                        onPressed: onEditTap,
                      ),
                    if (onDeleteTap != null)
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                        onPressed: onDeleteTap,
                      ),
                  ],
                ),
              ],
            ),
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                description!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تعداد: $totalQty x قیمت: $unitPrice',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                Row(
                  children: [
                    Text(
                      'کل: ${subTotal?.toStringAsFixed(0) ?? '0'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE53935),
                      ),
                    ),
                    if (onPlusTap != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.add_circle, color: Color(0xFFE53935), size: 22),
                        onPressed: onPlusTap,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}