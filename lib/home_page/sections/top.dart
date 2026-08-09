import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../controllers/item_controller.dart';
import 'sections_controller.dart';
import '../../welcome/login_page.dart';

class TopSection extends StatefulWidget {
  const TopSection({super.key});

  @override
  State<TopSection> createState() => _TopSectionState();
}

class _TopSectionState extends State<TopSection> {
  @override
  Widget build(BuildContext context) {
    // 🎯 ValueListenableBuilder میں فالتو '_' کے بجائے سیدھا ValueListenable بائنڈ کیا گیا ہے
    return ValueListenableBuilder(
      valueListenable: Hive.isBoxOpen('bankBox')
          ? Hive.box('bankBox').listenable()
          : ValueNotifier(null),
      builder: (context, box, child) {
        return ListenableBuilder(
          listenable: Listenable.merge([itemController, sectionsController]),
          builder: (context, child) {
            
            // 🎯 bankBox کی تمام کیز کا لائیو مجموعہ
            double totalCashAndBank = 0.0;
            if (Hive.isBoxOpen('bankBox')) {
              var bankBox = Hive.box('bankBox');
              for (var key in bankBox.keys) {
                var value = bankBox.get(key);
                if (value != null) {
                  double val = double.tryParse(value.toString()) ?? 0.0;
                  totalCashAndBank += val;
                }
              }
            }

            // اسٹاک کا کل رقم
            double totalStockAmount = itemController.items.fold(
              0.0,
              (sum, item) => sum + (item.quantity * item.purchasePrice),
            );

            // لائیو مجموعہ (Total Red & Total Green)
            String totalRedText = sectionsController.totalRedAmount.toInt().toString();
            String totalGreenText = sectionsController.totalGreenAmount.toInt().toString();

            return Column(
              children: [
                Container(
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // لائیو کیش + بینک بیلنس ڈسپلے
                      Text(
                        "Rs. ${totalCashAndBank.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            "نایاب قسط پوائنٹ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            onSelected: (value) {
                              if (value == 'logout') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginPage()),
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout, color: Colors.red, size: 20),
                                    SizedBox(width: 8),
                                    Text('لاگ آؤٹ (Logout)', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      // 1. آپ نے لینے ہیں (Red)
                      _buildButton("آپ نے لینے ہیں", totalRedText, Colors.red, "get"),
                      const SizedBox(width: 8),

                      // 2. آپ نے دینے ہیں (Green)
                      _buildButton("آپ نے دینے ہیں", totalGreenText, Colors.green, "give"),
                      const SizedBox(width: 8),

                      // 3. اسٹاک (Stock)
                      _buildButton("اسٹاک", totalStockAmount.toInt().toString(), Colors.blue, "stock"),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildButton(String title, String amount, Color color, String id) {
    bool isSelected = sectionsController.selectedTopButton == id;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          sectionsController.selectTopButton(id);
        },
        child: AnimatedScale(
          scale: isSelected ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected ? color.withAlpha(50) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  amount,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}