import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../controllers/item_controller.dart';
import '../../welcome/login_page.dart';
import 'sections_controller.dart';
import 'top_section_helper.dart'; // ہیلپر امپورٹ کریں

class TopSection extends StatelessWidget {
  const TopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        if (Hive.isBoxOpen('bankBox')) Hive.box('bankBox').listenable(),
        if (Hive.isBoxOpen('transactionBox')) Hive.box('transactionBox').listenable(),
        if (Hive.isBoxOpen('customerBox')) Hive.box('customerBox').listenable(),
        itemController,
        sectionsController,
      ]),
      builder: (context, _) {
        final totalBank = TopSectionHelper.getBankTotal();
        final custTotals = TopSectionHelper.getCustomerTotals();
        final totalStock = itemController.items.fold(0.0, (sum, i) => sum + (i.quantity * i.purchasePrice));
        final cardWidth = (MediaQuery.of(context).size.width - 24) / 2;

        final cardsData = [
          {"id": "get", "title": "آپ نے لینے ہیں", "amount": custTotals['red']!.toInt().toString(), "color": Colors.red},
          {"id": "give", "title": "آپ نے دینے ہیں", "amount": custTotals['green']!.toInt().toString(), "color": Colors.green},
          {"id": "stock", "title": "اسٹاک", "amount": totalStock.toInt().toString(), "color": Colors.blue},
        ];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Rs. ${totalBank.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      const Text("نایاب قسط پوائنٹ", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (v) {
                          if (v == 'logout') {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                          }
                        },
                        itemBuilder: (_) => [const PopupMenuItem(value: 'logout', child: Text('لاگ آؤٹ', style: TextStyle(fontWeight: FontWeight.bold)))],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: cardsData.map((item) {
                  bool isSelected = sectionsController.selectedTopButton == item['id'];
                  Color col = item['color'] as Color;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () => sectionsController.selectTopButton(item['id'] as String),
                      child: Container(
                        width: cardWidth,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? col.withValues(alpha: 0.12) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: col, width: isSelected ? 2 : 1.2),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1.5))],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(item['title'] as String, style: TextStyle(color: col, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1),
                            const SizedBox(height: 4),
                            Text("Rs. ${item['amount']}", style: TextStyle(color: col, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}