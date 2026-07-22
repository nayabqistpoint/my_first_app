import 'package:flutter/material.dart';

class ItemSelectorRowWidget extends StatelessWidget {
  final bool hasItems;
  final String itemName;
  final int totalQty;
  final double subTotal;
  final VoidCallback onTap;
  final VoidCallback? onScanTap;

  const ItemSelectorRowWidget({
    super.key,
    required this.hasItems,
    this.itemName = '',
    this.totalQty = 0,
    this.subTotal = 0.0,
    required this.onTap,
    this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasItems) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE53935), width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_circle_outline, size: 20, color: Color(0xFFE53935)),
              SizedBox(width: 8),
              Text(
                'ایڈ آئٹم',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 20, color: Color(0xFFE53935)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemName,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text('تعداد: $totalQty پیس', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rs ${subTotal.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner, size: 20, color: Color(0xFFE53935)),
                  onPressed: onScanTap ?? () {},
                  tooltip: 'بارکوڈ اسکین کریں',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ترمیم',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}