import 'package:flutter/material.dart';

class ItemSelectorRowWidget extends StatelessWidget {
  final bool hasItems;
  final String? itemName;
  final int? totalQty;
  final double? unitPrice;
  final double? subTotal;
  final String? description;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onPlusTap;
  final VoidCallback? onDeleteTap;

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
    this.onPlusTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasItems) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE53935)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Color(0xFFE53935), size: 24),
              SizedBox(width: 8),
              Text(
                'نیا آئٹم درج کریں',
                style: TextStyle(color: Color(0xFFE53935), fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. ماڈل کا نام اور تفصیل
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName ?? '',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 2. سب ٹوٹل اور کوانٹٹی ضرب پرائس (نیچے)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs ${(subTotal ?? 0).toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
                ),
                const SizedBox(height: 2),
                Text(
                  '${totalQty ?? 0} × ${(unitPrice ?? 0).toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 3. ایکشن بٹنز (پینسل، ڈیلیٹ بالٹی، اور مزید بڑا پلس آئکن)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ترمیم (پینسل)
              InkWell(
                onTap: onEditTap,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                ),
              ),
              const SizedBox(width: 4),

              // ڈیلیٹ (بالٹی / باسکٹ) - اب پینسل کے بالکل ساتھ لازمی نظر آئے گی
              InkWell(
                onTap: onDeleteTap,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline, size: 19, color: Colors.red),
                ),
              ),
              const SizedBox(width: 4),

              // مزید بڑا پلس (+) بٹن (صرف آخری رو پر)
              if (onPlusTap != null)
                InkWell(
                  onTap: onPlusTap,
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(Icons.add_circle, size: 26, color: Color(0xFFE53935)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}