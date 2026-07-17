import 'package:flutter/material.dart';
import 'inventory_widgets/add_stock_dialog.dart'; 
import 'inventory_widgets/stock_list_view.dart'; 

// پروڈکٹ اسٹاک کا ماڈل (اب سپلائر کے فیلڈ کے ساتھ)
class InventoryProduct {
  final String category;
  final String model;
  int stockQty;
  double purchasePrice;
  final String imei;
  final String supplier; // یہ نیا فیلڈ ایڈ کر دیا

  InventoryProduct({
    required this.category,
    required this.model,
    required this.stockQty,
    required this.purchasePrice,
    required this.supplier, // لازمی فیلڈ
    this.imei = '',
  });
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final String _searchQuery = "";
  final String _selectedFilter = "آل";

  // مین اسٹاک لسٹ (ڈیمو ڈیٹا میں سپلائر کا نام شامل کر دیا)
  final List<InventoryProduct> _stockViewList = [
    InventoryProduct(category: 'Mobile', model: 'Samsang A32', stockQty: 5, purchasePrice: 45000, supplier: 'Ali Mobiles'),
    InventoryProduct(category: 'Accessories', model: 'Type-C Charger 18W', stockQty: 20, purchasePrice: 650, supplier: 'Khan Traders'),
  ];

  Future<void> _openAddStockDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false, 
      builder: (context) => const AddStockDialog(),
    );

    if (result == null) return;
    if (!mounted) return;

    setState(() {
      final String supplierNameFromDialog = result['supplier'] as String; // ڈائیلاگ سے سپلائر کا نام لیا
      final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(result['items']);

      for (var item in items) {
        final String category = item['category'] as String;
        final String model = item['model'] as String;
        final int qty = item['qty'] as int;
        final double price = item['price'] as double;
        final String imei = item['imei'] as String;

        if (qty <= 0) continue; 

        // چیک کریں کہ کیا یہ ماڈل، کیٹیگری اور سپلائر پہلے سے لسٹ میں موجود ہے؟
        final existingIndex = _stockViewList.indexWhere(
          (p) => p.model.trim().toLowerCase() == model.trim().toLowerCase() && 
                 p.category.trim().toLowerCase() == category.trim().toLowerCase() &&
                 p.supplier.trim().toLowerCase() == supplierNameFromDialog.trim().toLowerCase()
        );

        if (existingIndex != -1) {
          // اگر موجود ہے، تو نکال کر دوبارہ ٹاپ پر اپڈیٹ کریں
          final existingItem = _stockViewList.removeAt(existingIndex);
          
          existingItem.stockQty += qty;
          existingItem.purchasePrice = price; 

          _stockViewList.insert(0, existingItem);
        } else {
          // اگر بالکل نیا ہے تو سپلائر کے نام کے ساتھ ٹاپ پر انسرٹ کریں
          _stockViewList.insert(
            0,
            InventoryProduct(
              category: category,
              model: model,
              stockQty: qty,
              purchasePrice: price,
              supplier: supplierNameFromDialog, // ڈائیلاگ والا سپلائر نام یہاں پاس کر دیا
              imei: imei,
            ),
          );
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("نیا اسٹاک محفوظ ہو گیا اور لسٹ میں سب سے اوپر شامل کر دیا گیا ہے!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("سٹاک اور انوینٹری مینجمنٹ"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 6, right: 4),
              child: Text(
                "موجودہ سٹاک لسٹ (Stock View List)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueGrey),
                textAlign: TextAlign.right,
              ),
            ),
            
            Expanded(
              child: StockListView(
                stockList: _stockViewList,
                searchQuery: _searchQuery,
                selectedFilter: _selectedFilter,
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _openAddStockDialog,
                icon: const Icon(Icons.add_box, color: Colors.white, size: 20),
                label: const Text("نیا اسٹاک / پرچیز بل درج کریں", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}