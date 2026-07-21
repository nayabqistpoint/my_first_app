import 'package:flutter/material.dart';
import '../controllers/item_controller.dart';

class ItemsPage extends StatelessWidget {
  const ItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ListenableBuilder(
          listenable: itemController,
          builder: (context, child) {
            final displayList = itemController.filteredItems;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
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
                            onChanged: (value) {
                              itemController.updateSearchQuery(value);
                            },
                            decoration: InputDecoration(
                              hintText: "تلاش کریں (${itemController.searchFilter})...",
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
                          initialValue: itemController.searchFilter,
                          icon: const Icon(Icons.filter_list, size: 16, color: Colors.deepPurple),
                          padding: EdgeInsets.zero,
                          color: Colors.white,
                          elevation: 3,
                          onSelected: (String value) {
                            itemController.updateFilter(value);
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
                    child: displayList.isEmpty
                        ? const Center(
                            child: Text(
                              "کوئی اسٹاک موجود نہیں ہے\nبراہ کرم نیا اسٹاک شامل کریں",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.bold),
                            ),
                          )
                        : ListView.builder(
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              final item = displayList[index];
                              return _buildStockItem(
                                item.name,
                                item.imei,
                                item.quantity,
                                item.purchasePrice,
                                item.salePrice,
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // اسٹاک آئٹم کا ڈیزائن جس میں خرید اور فروخت دونوں قیمتیں شامل ہیں
  Widget _buildStockItem(String mobileName, String imei, int qty, double purchasePrice, double salePrice) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // دائیں طرف: نام، پیس اور IMEI
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
                  Text(imei, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)),
                ],
              ),
              // بائیں طرف: خرید قیمت اور فروخت قیمت کی تفصیل
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "فروخت: Rs ${salePrice.toInt()}", 
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "خرید: Rs ${purchasePrice.toInt()}", 
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent)
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