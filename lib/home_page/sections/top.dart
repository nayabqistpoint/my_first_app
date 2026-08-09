import 'package:flutter/material.dart';
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
    return ListenableBuilder(
      listenable: Listenable.merge([itemController, sectionsController]),
      builder: (context, child) {
        // تمام آئٹمز کے سب ٹوٹل کا گرینڈ ٹوٹل
        double totalStockAmount = itemController.items.fold(
          0.0,
          (sum, item) => sum + (item.quantity * item.purchasePrice),
        );

        return Column(
          children: [
            Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Rs. 0.00",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Text(
                        "نایاب قسط پوائنٹ",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                  _buildButton("You Will Get", "50,000", Colors.red, "get"),
                  const SizedBox(width: 8),
                  _buildButton("You Will Give", "20,000", Colors.green, "give"),
                  const SizedBox(width: 8),
                  _buildButton("Stock", totalStockAmount.toInt().toString(), Colors.blue, "stock"),
                ],
              ),
            ),
          ],
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  amount,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
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