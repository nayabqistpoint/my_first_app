import 'package:flutter/material.dart';
import 'inventory_widgets/single_item_data.dart'; 
import 'inventory_widgets/inventory_summary_card.dart'; 
import 'inventory_widgets/search_and_filter_section.dart'; 
import 'inventory_widgets/stock_list_view.dart'; 
import 'inventory_widgets/add_stock_dialog.dart'; 

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  // ہمارا لائیو اسٹاک ڈیٹا (نئے ماڈل کی مطابقت کے ساتھ)
  final List<SingleItemData> _stockList = [
    SingleItemData(
      id: '1',
      billId: 'BILL-INIT-1',
      model: 'Vivo Y17s',
      supplier: 'Ali Mobiles',
      category: 'موبائل',
      purchasePrice: 34500,
      quantity: 1,
      date: '2026-07-16',
      imei: '861234567890123',
    ),
    SingleItemData(
      id: '2',
      billId: 'BILL-INIT-2',
      model: 'Oppo A18',
      supplier: 'Zeeshan Traders',
      category: 'موبائل',
      purchasePrice: 32000,
      quantity: 1,
      date: '2026-07-15',
      imei: '869876543210987',
    ),
  ];

  String _searchQuery = '';
  String _selectedFilter = 'آل'; // آل، آئٹم، سپلائر

  // کل سرمایہ کاری کا حساب لگانے والا لاجک (قیمت کو تعداد سے ضرب دے کر)
  int get _totalInvestment {
    return _stockList.fold(0, (sum, item) => sum + (item.purchasePrice * item.quantity));
  }

  // کل اسٹاک کی تعداد
  int get _totalItems => _stockList.length;

  // ایڈ اسٹاک پاپ اپ کو کھولنے والا فنکشن
  void _openAddStockDialog() async {
    // پاپ اپ اب میپ (Map) ریٹرن کرتا ہے جس میں بل کا پورا ریکارڈ موجود ہوتا ہے
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false, // پاپ اپ سے باہر کلک کرنے پر بند نہیں ہوگا
      builder: (BuildContext context) {
        return const AddStockDialog();
      },
    );

    // سیکیورٹی گارڈ جو سکرین بند ہونے پر آگے کام کرنے سے روکے گا
    if (!mounted) return; 

    // اگر یوزر نے کامیابی سے بل ایڈ کیا ہے تو اس کی تمام آئٹمز کو لسٹ میں شامل کریں
    if (result != null && result['items'] != null) {
      final List<SingleItemData> newItems = List<SingleItemData>.from(result['items']);
      
      setState(() {
        _stockList.addAll(newItems);
      });
      
      // کامیابی کا میسج نیچے دکھائیں
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newItems.length} آئٹمز کامیابی سے بل کے ساتھ اسٹاک میں شامل کر دیے گئے ہیں!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      
      appBar: AppBar(
        title: const Text(
          'اسٹاک انوینٹری',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A8A), 
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () {
              // کیمرہ اسکینر کا لاجک یہاں آئے گا
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ۱۔ انویسٹمنٹ کارڈ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: InventorySummaryCard(
                totalInvestment: _totalInvestment,
                totalItems: _totalItems,
              ),
            ),

            // ۲۔ سرچ بار اور فلٹر چپس
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: SearchAndFilterSection(
                searchQuery: _searchQuery,
                selectedFilter: _selectedFilter,
                onSearchChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onFilterChanged: (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            // ۳۔ لائیو اور اسمارٹ موبائلز کی لسٹ والا حصہ
            Expanded(
              child: StockListView(
                stockList: _stockList, 
                searchQuery: _searchQuery,
                selectedFilter: _selectedFilter,
              ),
            ),
          ],
        ),
      ),

      // نیچے بائیں طرف والا فلوٹنگ بٹن (Add Stock)
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddStockDialog, 
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}