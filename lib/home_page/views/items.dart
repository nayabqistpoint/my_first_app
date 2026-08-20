import 'package:flutter/material.dart';
import 'package:my_first_app/home_page/views/item_controller.dart';

class ItemsPage extends StatelessWidget {
  const ItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: ListenableBuilder(
        listenable: itemController,
        builder: (context, child) {
          final displayList = itemController.filteredItems;

          if (displayList.isEmpty) {
            return const Center(
              child: Text(
                "کوئی اسٹاک موجود نہیں ہے",
                style: TextStyle(
                  fontSize: 14, 
                  color: Colors.black54, 
                  fontWeight: FontWeight.bold
                ),
              ),
            );
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final item = displayList[index];

                return _StockRowItem(
                  mobileName: item.name,
                  imei: item.imei,
                  purchasePrice: item.purchasePrice,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _StockRowItem extends StatelessWidget {
  final String mobileName;
  final String imei;
  final double purchasePrice;

  const _StockRowItem({
    required this.mobileName,
    required this.imei,
    required this.purchasePrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mobileName,
                  style: const TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.black,
                  ),
                ),
                if (imei.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    imei,
                    style: const TextStyle(
                      fontSize: 12, 
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            "Rs ${purchasePrice.toInt()}",
            style: const TextStyle(
              fontSize: 15, 
              fontWeight: FontWeight.bold, 
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}