import 'package:flutter/material.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  String _searchFilter = "بذریعہ نام"; 

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 4.0, bottom: 4.0),
          child: Column(
            children: [
              // 1. سرچ بار اور فلٹر
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 34,
                      child: TextField(
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: "تلاش کریں ($_searchFilter)...",
                          prefixIcon: const Icon(Icons.search, size: 16, color: Colors.black54),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Colors.black87, width: 1.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    height: 34,
                    width: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black87, width: 1.3),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: PopupMenuButton<String>(
                      initialValue: _searchFilter,
                      icon: const Icon(Icons.filter_list, size: 16, color: Colors.deepPurple),
                      padding: EdgeInsets.zero,
                      color: Colors.white,
                      elevation: 3,
                      onSelected: (String value) {
                        setState(() {
                          _searchFilter = value;
                        });
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(value: 'بذریعہ نام', child: Text('بذریعہ نام', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                        const PopupMenuDivider(height: 1),
                        const PopupMenuItem<String>(value: 'بذریعہ IMEI', child: Text('بذریعہ IMEI', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                        const PopupMenuDivider(height: 1),
                        const PopupMenuItem<String>(value: 'بذریعہ اسٹاک', child: Text('بذریعہ اسٹاک', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 2. موبائل اسٹاک کی لسٹ
              Expanded(
                child: ListView(
                  children: [
                    _buildStockItem("Vivo Y20", "IMEI: 864201937592014", 40, 25000),
                    _buildStockItem("Samsung A32", "IMEI: 359402104729481", 15, 45000),
                    _buildStockItem("Oppo A54", "IMEI: 869302047194628", 22, 32000),
                    _buildStockItem("Infinix Hot 12", "IMEI: 352940104827492", 50, 22000),
                    _buildStockItem("Redmi Note 11", "IMEI: 861048294710482", 12, 38000),
                    _buildStockItem("Realme C35", "IMEI: 358204810472947", 30, 28000),
                    _buildStockItem("Tecno Spark 8", "IMEI: 862048194729471", 18, 19500),
                    _buildStockItem("iPhone 13", "IMEI: 351947204819472", 5, 180000),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // نیا سمارٹ آئٹم ڈیزائن
  Widget _buildStockItem(String mobileName, String imei, int qty, int purchasePrice) {
    int totalValue = qty * purchasePrice; 

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0), // متوازن پیڈنگ
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // دائیں طرف: موبائل کا نام، پیس اور بڑا بولڈ IMEI نمبر
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(mobileName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                      Text(" - $qty پیس", style: const TextStyle(fontSize: 12, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // IMEI نمبر کو بڑا اور بولڈ کر دیا ہے
                  Text(imei, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)),
                ],
              ),
              // بائیں طرف: خوبصورت گرین ٹوٹل رقم اور نیچے بولڈ کیلکولیشن
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // خوبصورت گرین (سبز) رنگ میں ٹوٹل رقم
                  Text(
                    "Rs $totalValue", 
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green)
                  ),
                  const SizedBox(height: 3),
                  // کیلکولیشن کو بولڈ کر دیا تاکہ آسانی سے پڑھی جائے
                  Text(
                    "$qty × $purchasePrice", 
                    style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.4), 
      ],
    );
  }
}