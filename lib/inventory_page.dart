import 'package:flutter/material.dart';
// نیچے والی لائن میں اپنے پروجیکٹ کا نام درست کر لیں (جیسے 'my_app') یا رِلیٹو پاتھ استعمال کریں:
import 'inventory_widgets/add_stock_dialog.dart'; 

// پروڈکٹ اسٹاک کو سنبھالنے کے لیے ماڈل (जो व्यू लिस्ट में नजर आएगा)
class InventoryProduct {
  final String category;
  final String model;
  int stockQty;
  double purchasePrice;
  final String imei;

  InventoryProduct({
    required this.category,
    required this.model,
    required this.stockQty,
    required this.purchasePrice,
    this.imei = '',
  });
}

// ریسنٹ آرڈرز / ٹرانزیکشن ہسٹری کے لیے ماڈل
class StockOrderLog {
  final String supplierName;
  final DateTime date;
  final int totalItems;
  final double grandTotal;
  final double remainingBalance;
  final bool sharedOnWhatsApp;

  StockOrderLog({
    required this.supplierName,
    required this.date,
    required this.totalItems,
    required this.grandTotal,
    required this.remainingBalance,
    required this.sharedOnWhatsApp,
  });
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  // مین اسٹاک لسٹ (ڈیش بورڈ / اسٹاک ویو لسٹ)
  final List<InventoryProduct> _stockViewList = [
    InventoryProduct(category: 'Mobile', model: 'Samsang A32', stockQty: 5, purchasePrice: 45000),
    InventoryProduct(category: 'Accessories', model: 'Type-C Charger 18W', stockQty: 20, purchasePrice: 650),
  ];

  // ریسنٹ آرڈرز لاگ کی لسٹ
  final List<StockOrderLog> _recentOrdersList = [
    StockOrderLog(
      supplierName: 'Ali Mobiles',
      date: DateTime.now().subtract(const Duration(days: 1)),
      totalItems: 2,
      grandTotal: 15000,
      remainingBalance: 0.0,
      sharedOnWhatsApp: true,
    )
  ];

  // ڈائیلاگ کو اوپن کرنے اور ڈیٹا وصول کر کے ریل ٹائم سنکرونائز کرنے کا فکسڈ فنکشن
  Future<void> _openAddStockDialog() async {
    // ڈائیلاگ کھولیں اور یوزر کا سبمٹ کردہ ڈیٹا وصول کریں
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false, // باہر کلک کرنے سے بند نہ ہو
      builder: (context) => const AddStockDialog(),
    );

    // اگر یوزر نے ڈائیلاگ بند کر دیا یا کینسل کر دیا تو آگے کچھ نہ کریں
    if (result == null) return;

    // ائسکرونیس گیپ (async gap) کے بعد کنٹیکسٹ استعمال کرنے سے پہلے یہ چیک لازمی ہے تاکہ ایرر نہ آئے
    if (!mounted) return;

    // ریل ٹائم ڈیٹا پروسیسنگ اور سنکرونائزیشن
    setState(() {
      final String supplier = result['supplier'] as String;
      final DateTime date = result['date'] as DateTime;
      final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(result['items']);
      final double total = result['total'] as double;
      final double balance = result['balance'] as double;
      final bool shouldShare = result['shouldShare'] as bool;

      int totalQtyInOrder = 0;

      // 1۔ اسٹاک ویو لسٹ (Stock View List) کو ریل ٹائم اپ ڈیٹ کرنا
      for (var item in items) {
        final String category = item['category'] as String;
        final String model = item['model'] as String;
        final int qty = item['qty'] as int;
        final double price = item['price'] as double;
        final String imei = item['imei'] as String;

        if (qty <= 0) continue; // اگر تعداد 0 ہے تو اسٹاک میں شامل نہ کریں
        totalQtyInOrder += qty;

        // چیک کریں کہ کیا یہ ماڈل اور کیٹیگری پہلے سے اسٹاک لسٹ میں موجود ہے؟
        final existingIndex = _stockViewList.indexWhere(
          (p) => p.model.trim().toLowerCase() == model.trim().toLowerCase() && 
                 p.category.trim().toLowerCase() == category.trim().toLowerCase()
        );

        if (existingIndex != -1) {
          // اگر موجود ہے تو تعداد بڑھائیں اور اوسط قیمتِ خرید اپ ڈیٹ کریں
          _stockViewList[existingIndex].stockQty += qty;
          _stockViewList[existingIndex].purchasePrice = price; // تازہ ترین قیمت پر سیٹ کریں
        } else {
          // اگر بالکل نیا ماڈل ہے تو لسٹ میں نیا ریکارڈ بنائیں
          _stockViewList.add(
            InventoryProduct(
              category: category,
              model: model,
              stockQty: qty,
              purchasePrice: price,
              imei: imei,
            ),
          );
        }
      }

      // 2۔ ریسنٹ آرڈر لاگ (Recent Order Log) میں یہ نیا بل شامل کرنا
      _recentOrdersList.insert(
        0, // تاکہ نیا آرڈر لسٹ میں سب سے اوپر نظر آئے
        StockOrderLog(
          supplierName: supplier,
          date: date,
          totalItems: totalQtyInOrder,
          grandTotal: total,
          remainingBalance: balance,
          sharedOnWhatsApp: shouldShare,
        ),
      );

      // اگر یوزر نے "محفوظ کریں اور واٹس ایپ کریں" کا انتخاب کیا تھا
      if (shouldShare) {
        _shareInvoiceOnWhatsApp(supplier, total, balance);
      }
    });

    // کامیابی کا پیغام دکھائیں (محفوظ طریقے سے)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("نیا اسٹاک کامیابی سے محفوظ اور سنکرونائز ہو گیا ہے!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // واٹس ایپ پر رسیڈ بھیجنے کا عارضی ڈیمو لاجک (یہ آگے چل کر باقاعدہ کنیکٹ ہو جائے گا)
  void _shareInvoiceOnWhatsApp(String supplier, double total, double balance) {
    debugPrint("WhatsApp API Triggered for $supplier. Total: $total, Balance: $balance");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("سٹاک اور انوینٹری مینجمنٹ"),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // لسٹ ریفریش کرنے کے لیے
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // اوپر اسٹاک لسٹ (Stock View List) کا سیکشن
            const Text(
              "موجودہ ستک لسٹ (Stock View List)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey),
            ),
            const SizedBox(height: 4),
            Expanded(
              flex: 5,
              child: Card(
                elevation: 2,
                child: _stockViewList.isEmpty
                    ? const Center(child: Text("سٹاک میں کوئی چیز موجود نہیں ہے"))
                    : ListView.separated(
                        itemCount: _stockViewList.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final product = _stockViewList[index];
                          return ListTile(
                            dense: true,
                            title: Text(product.model, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text("کیٹیگری: ${product.category} | IMEI: ${product.imei.isEmpty ? 'N/A' : product.imei}", style: const TextStyle(fontSize: 11)),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("تعداد: ${product.stockQty}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                                Text("قیمت: Rs. ${product.purchasePrice.toStringAsFixed(0)}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 10),

            // نیچے ریسنٹ آرڈرز (Recent Orders) کا سیکشن
            const Text(
              "ریسنٹ آرڈر لاگ (Recent Order History)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey),
            ),
            const SizedBox(height: 4),
            Expanded(
              flex: 4,
              child: Card(
                elevation: 2,
                color: Colors.grey[50],
                child: _recentOrdersList.isEmpty
                    ? const Center(child: Text("ابھی تک کوئی آرڈر درج نہیں کیا گیا"))
                    : ListView.separated(
                        itemCount: _recentOrdersList.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final order = _recentOrdersList[index];
                          final formattedDate = "${order.date.day}/${order.date.month}/${order.date.year}";
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              order.sharedOnWhatsApp ? Icons.check_circle : Icons.offline_pin,
                              color: order.sharedOnWhatsApp ? Colors.green : Colors.grey,
                              size: 20,
                            ),
                            title: Text(order.supplierName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            subtitle: Text("تاریخ: $formattedDate | کل آئٹمز: ${order.totalItems}", style: const TextStyle(fontSize: 10)),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Rs. ${order.grandTotal.toStringAsFixed(0)}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                Text(
                                  order.remainingBalance > 0 ? "باقی: Rs. ${order.remainingBalance.toStringAsFixed(0)}" : "آل پیڈ",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: order.remainingBalance > 0 ? Colors.red : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 8),

            // مین بٹن جس سے نیا فائنل ڈائیلاگ کھلے گا
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _openAddStockDialog,
                icon: const Icon(Icons.add_box, color: Colors.white, size: 18),
                label: const Text("نیا اسٹاک / پرچیز بل درج کریں", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}