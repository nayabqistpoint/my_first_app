import 'package:flutter/material.dart';
import 'inventory_widgets/add_stock_dialog.dart'; 
import 'inventory_widgets/stock_list_view.dart'; 

// پروڈکٹ اسٹاک کا ماڈل (اب سپلائر اور انوائس نمبر کے ساتھ)
class InventoryProduct {
  final String category;
  final String model;
  int stockQty;
  double purchasePrice;
  final String imei;
  final String supplier; 
  final String invoiceNumber; 

  InventoryProduct({
    required this.category,
    required this.model,
    required this.stockQty,
    required this.purchasePrice,
    required this.supplier, 
    required this.invoiceNumber,
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

  // مین اسٹاک لسٹ (ابتدائی ڈیمو ڈیٹا اسپلٹ لاجک کے ساتھ)
  final List<InventoryProduct> _stockViewList = [
    InventoryProduct(
      category: 'Mobile', 
      model: 'Samsang A32', 
      stockQty: 2, 
      purchasePrice: 45000, 
      supplier: 'Ali Mobiles',
      invoiceNumber: 'INV-101',
      imei: '358941101234567'
    ),
    InventoryProduct(
      category: 'Mobile', 
      model: 'Samsang A32', 
      stockQty: 3, 
      purchasePrice: 47000, 
      supplier: 'Nasir Mobiles', 
      invoiceNumber: 'INV-102', 
      imei: '358941109876543'
    ),
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
      final String supplierNameFromDialog = result['supplier'] as String;
      final String invoiceNo = result['invoice'] ?? "INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
      final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(result['items']);

      for (var item in items) {
        final String category = item['category'] as String;
        final String model = item['model'] as String;
        final int qty = item['qty'] as int;
        final double price = item['price'] as double;
        final String imei = item['imei'] as String;

        if (qty <= 0) continue; 

        _stockViewList.insert(
          0,
          InventoryProduct(
            category: category,
            model: model,
            stockQty: qty,
            purchasePrice: price,
            supplier: supplierNameFromDialog,
            invoiceNumber: invoiceNo,
            imei: imei,
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("نیا اسٹاک سپلائر اور انوائس وائز الگ محفوظ کر کے ٹاپ پر شامل کر دیا گیا ہے!"),
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