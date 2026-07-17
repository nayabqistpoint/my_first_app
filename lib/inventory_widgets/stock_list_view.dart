import 'package:flutter/material.dart';
import 'single_item_data.dart';

class StockListView extends StatelessWidget {
  final List<SingleItemData> stockList;
  final String searchQuery;
  final String selectedFilter; // 'آل'، 'آئٹم'، 'سپلائر'

  const StockListView({
    super.key,
    required this.stockList,
    required this.searchQuery,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    // ۱۔ پہلے سرچ فلٹر لاگو کریں
    final filteredList = stockList.where((item) {
      final query = searchQuery.toLowerCase();
      return item.model.toLowerCase().contains(query) ||
          item.supplier.toLowerCase().contains(query) ||
          item.imei.contains(query);
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

    // ۲۔ اب منتخب کردہ چِپ (Filter) کے حساب سے ڈیٹا دکھائیں
    if (selectedFilter == 'آئٹم') {
      return _buildItemGroupedList(filteredList);
    } else if (selectedFilter == 'سپلائر') {
      return _buildSupplierGroupedList(filteredList);
    } else {
      return _buildAllStockList(filteredList);
    }
  }

  // الف: تمام اسٹاک کی سادہ اور خوبصورت لسٹ (All Stock)
  Widget _buildAllStockList(List<SingleItemData> items) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // موبائل کا خوبصورت گول آئیکن
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone_android, color: Color(0xFF1E3A8A), size: 24),
                ),
                const SizedBox(width: 14),
                // موبائل کی معلومات
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.model,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'سپلائر: ${item.supplier}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'IMEI: ${item.imei}',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
                // قیمت اور تاریخ
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs. ${item.purchasePrice}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.date,
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ب: آئٹم وائز گروپ لسٹ (Grouped by Item/Model)
  Widget _buildItemGroupedList(List<SingleItemData> items) {
    // ماڈل کے حساب سے ڈیٹا اکٹھا کرنا
    final Map<String, List<SingleItemData>> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item.model, () => []).add(item);
    }

    final keys = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final modelName = keys[index];
        final modelItems = grouped[modelName]!;
        final totalQty = modelItems.length;
        final totalVal = modelItems.fold(0, (sum, item) => sum + item.purchasePrice);

        return Card(
          color: Colors.white,
          elevation: 1.5,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: CircleAvatar(
              backgroundColor: Colors.teal.withValues(alpha: 0.1),
              child: const Icon(Icons.category_outlined, color: Colors.teal),
            ),
            title: Text(
              modelName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text('تعداد: $totalQty سیٹ'),
            trailing: Text(
              'Rs. $totalVal',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.teal),
            ),
          ),
        );
      },
    );
  }

  // ج: سپلائر وائز گروپ لسٹ (Grouped by Supplier)
  Widget _buildSupplierGroupedList(List<SingleItemData> items) {
    // سپلائرز کے حساب سے ڈیٹا اکٹھا کرنا
    final Map<String, List<SingleItemData>> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item.supplier, () => []).add(item);
    }

    final keys = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final supplierName = keys[index];
        final supplierItems = grouped[supplierName]!;
        final totalQty = supplierItems.length;
        final totalVal = supplierItems.fold(0, (sum, item) => sum + item.purchasePrice);

        return Card(
          color: Colors.white,
          elevation: 1.5,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withValues(alpha: 0.1),
              child: const Icon(Icons.person_outline, color: Colors.purple),
            ),
            title: Text(
              supplierName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text('خریدے گئے سیٹ: $totalQty'),
            trailing: Text(
              'Rs. $totalVal',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.purple),
            ),
          ),
        );
      },
    );
  }
}