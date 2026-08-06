import 'package:flutter/material.dart';

class ItemSelectorRowWidget extends StatelessWidget {
  final String itemName;
  final String imeiNo;
  final String subTotal;
  final String calculationText;
  final VoidCallback onAddPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onEditPressed;
  final VoidCallback onRowPressed;

  const ItemSelectorRowWidget({
    super.key,
    required this.itemName,
    required this.imeiNo,
    required this.subTotal,
    required this.calculationText,
    required this.onAddPressed,
    required this.onDeletePressed,
    required this.onEditPressed,
    required this.onRowPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.red.shade700, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onRowPressed,
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // دائیں طرف نارمل اور ہمیشہ فعال بٹنز
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.add_circle, color: Colors.green, size: 28),
                  onPressed: onAddPressed,
                ),
                const SizedBox(width: 6),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                  onPressed: onDeletePressed,
                ),
                const SizedBox(width: 6),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.edit, color: Colors.blue.shade700, size: 22),
                  onPressed: onEditPressed,
                ),

                const SizedBox(width: 8),

                // سب ٹوٹل اور حساب کتاب
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subTotal.isEmpty ? '0.00' : subTotal,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      calculationText.isEmpty ? '1 × 0' : calculationText,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // بائیں طرف آئٹم کا نام اور IMEI
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      itemName.isEmpty ? 'آئٹم کو منتخب کریں' : itemName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: itemName.isEmpty ? Colors.red.shade900 : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      imeiNo.isEmpty ? 'IMEI: درج نہیں' : 'IMEI: $imeiNo',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}