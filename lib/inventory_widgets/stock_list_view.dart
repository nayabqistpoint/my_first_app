import 'package:flutter/material.dart';
import '../inventory_page.dart';

class StockListView extends StatelessWidget {
  final List<InventoryProduct> stockList;
  final String searchQuery;
  final String selectedFilter;

  const StockListView({
    super.key,
    required this.stockList,
    required this.searchQuery,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    final filteredList = stockList.where((item) {
      final query = searchQuery.toLowerCase();
      return item.model.toLowerCase().contains(query) ||
             item.category.toLowerCase().contains(query) ||
             item.supplier.toLowerCase().contains(query) ||
             item.imei.toLowerCase().contains(query);
    }).toList();

    if (filteredList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'کوئی اسٹاک نہیں ملا!',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return _buildAllStockList(filteredList);
  }

  Widget _buildAllStockList(List<InventoryProduct> items) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final double itemTotal = item.stockQty * item.purchasePrice;

        return Card(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                // === بائیں طرف: کل رقم اور حساب ===
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rs. ${itemTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${item.stockQty} سیٹ × Rs. ${item.purchasePrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.grey.shade700, 
                          fontSize: 11,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                // === دائیں طرف: معلومات ===
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item.model,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'سپلائر: ${item.supplier} | کیٹیگری: ${item.category}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              textAlign: TextAlign.right,
                            ),
                            if (item.imei.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'IMEI: ${item.imei}',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontFamily: 'monospace'),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          // یہاں آپ کی بتائی ہوئی ڈپریکیٹڈ وارننگ فکس کر دی ہے
                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone_android, color: Color(0xFF1E3A8A), size: 20),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        );
      },
    );
  }
}