import 'package:flutter/material.dart';
import '../inventory_page.dart'; 
import 'single_item_data.dart'; 

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

  // تفصیلی پاپ اپ شو کرنے کا فنکشن
  void _showItemDetails(BuildContext context, String model, double price, List<SingleItemData> linkedItems) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ItemDetailBottomSheet(
        modelName: model,
        price: price,
        items: linkedItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. سرچ فلٹر لاگو کریں
    final filteredList = stockList.where((item) {
      final query = searchQuery.toLowerCase();
      return item.model.toLowerCase().contains(query) ||
             item.category.toLowerCase().contains(query) ||
             item.supplier.toLowerCase().contains(query) ||
             item.invoiceNumber.toLowerCase().contains(query) ||
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

    // فلٹر کے مطابق لسٹ رینڈر کریں
    if (selectedFilter == 'آئٹم') {
      return _buildItemGroupedList(context, filteredList);
    } else {
      return _buildAllStockList(context, filteredList);
    }
  }

  // الف: تمام اسٹاک کی مجموعی لسٹ (ماڈل اور قیمت کے حساب سے گروپ شدہ)
  Widget _buildAllStockList(BuildContext context, List<InventoryProduct> filteredItems) {
    final Map<String, List<InventoryProduct>> groupedMap = {};
    for (var item in filteredItems) {
      final key = '${item.model}_${item.purchasePrice}';
      if (!groupedMap.containsKey(key)) {
        groupedMap[key] = [];
      }
      groupedMap[key]!.add(item);
    }

    final List<String> groupedKeys = groupedMap.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      itemCount: groupedKeys.length,
      itemBuilder: (context, index) {
        final key = groupedKeys[index];
        final productsInGroup = groupedMap[key]!;
        
        final firstProduct = productsInGroup.first;
        final String modelName = firstProduct.model;
        final double purchasePrice = firstProduct.purchasePrice;
        
        int totalQty = 0;
        for (var p in productsInGroup) {
          totalQty += p.stockQty;
        }
        
        final double totalGroupValue = totalQty * purchasePrice;

        final List<SingleItemData> detailedItems = productsInGroup.map((p) {
          return SingleItemData(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            billId: p.invoiceNumber,
            model: p.model,
            category: p.category,
            purchasePrice: p.purchasePrice.toInt(),
            quantity: p.stockQty,
            imei: p.imei,
            supplier: p.supplier,
            date: "آج کا اسٹاک",
          );
        }).toList();

        return Card(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          clipBehavior: Clip.antiAlias, 
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            onTap: () {
              _showItemDetails(context, modelName, purchasePrice, detailedItems);
            },
            // بائیں طرف کی معلومات (ٹوٹل رقم اور درست ضرب کا حساب)
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rs. ${totalGroupValue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  // یہ رہا بالکل درست ٹیکسٹ پیٹرن جو خراب ہو گیا تھا
                  child: Text(
                    '$totalQty سیٹ × Rs. ${purchasePrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.grey.shade700, 
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              modelName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.right,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'کیٹیگری: ${firstProduct.category}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  textAlign: TextAlign.right,
                ),
                Text(
                  'تفصیل دیکھنے کے لیے کلک کریں...',
                  style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 10, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_android, color: Color(0xFF1E3A8A), size: 18),
            ),
          ),
        );
      },
    );
  }

  // ب: آئٹم وائز گروپ لسٹ (جب صرف ماڈل کے حساب سے دیکھنا ہو)
  Widget _buildItemGroupedList(BuildContext context, List<InventoryProduct> filteredItems) {
    final Map<String, List<InventoryProduct>> modelGroupedMap = {};
    for (var item in filteredItems) {
      if (!modelGroupedMap.containsKey(item.model)) {
        modelGroupedMap[item.model] = [];
      }
      modelGroupedMap[item.model]!.add(item);
    }

    final List<String> modelKeys = modelGroupedMap.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      itemCount: modelKeys.length,
      itemBuilder: (context, index) {
        final modelName = modelKeys[index];
        final productsInModelGroup = modelGroupedMap[modelName]!;
        
        int totalQty = 0;
        double totalValue = 0;
        for (var p in productsInModelGroup) {
          totalQty += p.stockQty;
          totalValue += (p.stockQty * p.purchasePrice);
        }

        final List<SingleItemData> detailedItems = productsInModelGroup.map((p) {
          return SingleItemData(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            billId: p.invoiceNumber,
            model: p.model,
            category: p.category,
            purchasePrice: p.purchasePrice.toInt(),
            quantity: p.stockQty,
            imei: p.imei,
            supplier: p.supplier,
            date: "آج کا اسٹاک",
          );
        }).toList();

        final double avgPrice = totalQty > 0 ? (totalValue / totalQty) : 0;

        return Card(
          color: Colors.white,
          elevation: 1.5,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          clipBehavior: Clip.antiAlias, 
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            onTap: () {
              _showItemDetails(context, modelName, avgPrice, detailedItems);
            },
            leading: Text(
              'Rs. ${totalValue.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
            ),
            title: Text(
              modelName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.right,
            ),
            subtitle: Text(
              'کل اسٹاک: $totalQty سیٹ', 
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.right,
            ),
            trailing: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.teal.withValues(alpha: 0.1),
              child: const Icon(Icons.category_outlined, color: Colors.teal, size: 16),
            ),
          ),
        );
      },
    );
  }
}