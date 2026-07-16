import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final List<Map<String, dynamic>> _stockItems = [
    {
      'model': 'Samsung A14',
      'supplier': 'Ali Mobile',
      'quantity': 5,
      'purchasePrice': 38000,
      'sellingPrice': 42000,
      'date': '10 July 2026',
    },
    {
      'model': 'Vivo Y17s',
      'supplier': 'Zeeshan Traders',
      'quantity': 3,
      'purchasePrice': 29000,
      'sellingPrice': 32500,
      'date': '12 July 2026',
    },
    {
      'model': 'Infinix Hot 30',
      'supplier': 'Ali Mobile',
      'quantity': 4,
      'purchasePrice': 31000,
      'sellingPrice': 34000,
      'date': '08 July 2026',
    },
    {
      'model': 'Tecno Spark 10',
      'supplier': 'Rehan Wholesale',
      'quantity': 2,
      'purchasePrice': 26000,
      'sellingPrice': 28500,
      'date': '05 July 2026',
    },
  ];

  int get _totalStockValue {
    return _stockItems.fold(
        0, (sum, item) => sum + ((item['purchasePrice'] as int) * (item['quantity'] as int)));
  }

  int get _totalItemsCount {
    return _stockItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }

  // یہاں ہم نے واشگاف کیا کہ آنے والا پیرامیٹر String ہی ہے
  void _openSupplierHistory(String supplierName) {
    final supplierPurchases =
        _stockItems.where((item) => item['supplier'] == supplierName).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierHistoryPage(
          supplierName: supplierName,
          purchases: supplierPurchases,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اسٹاک انوینٹری', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: const Color(0xFF0D47A1),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('کل اسٹاک کی مالیت (Total Stock Value)', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text('Rs. $_totalStockValue', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('کل موبائلز: $_totalItemsCount عدد', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('موجودہ اسٹاک آئٹمز', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('(سپلائر ہسٹری کے لیے ٹیپ کریں)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _stockItems.length,
                itemBuilder: (context, index) {
                  final item = _stockItems[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      // یہاں ہم نے 'as String' لکھ کر ڈارٹ کو بتا دیا کہ یہ لازمی ٹیکسٹ (String) ہے
                      onTap: () => _openSupplierHistory(item['supplier'] as String),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: const Icon(Icons.phone_android, color: Color(0xFF0D47A1)),
                      ),
                      title: Text(item['model'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('سپلائر: ${item['supplier']}\nخرید: Rs. ${item['purchasePrice']} | فروخت: Rs. ${item['sellingPrice']}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('تعداد: ${item['quantity']}', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SupplierHistoryPage extends StatelessWidget {
  final String supplierName;
  final List<Map<String, dynamic>> purchases;

  const SupplierHistoryPage({
    super.key,
    required this.supplierName,
    required this.purchases,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('سپلائر کھاتہ: $supplierName', style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF0D47A1),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView.builder(
          itemCount: purchases.length,
          itemBuilder: (context, index) {
            final item = purchases[index];
            return Card(
              margin: const EdgeInsets.all(12),
              child: ListTile(
                title: Text(item['model'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('تعداد: ${item['quantity']} عدد | فی موبائل: Rs. ${item['purchasePrice']}'),
                trailing: Text('ٹوٹل: Rs. ${(item['purchasePrice'] as int) * (item['quantity'] as int)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          },
        ),
      ),
    );
  }
}