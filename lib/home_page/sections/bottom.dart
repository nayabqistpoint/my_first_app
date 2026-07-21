import 'package:flutter/material.dart';
// یہ پاتھ درست ہے: ایک بار ../ سے lib فولڈر میں اور پھر مین فائل تک
import '../../installment_calculater_page.dart';
// خرید و فروخت فارم کا امپورٹ پاتھ
import '../transaction_forms/sale_purchase.dart';

class BottomSection extends StatelessWidget {
  const BottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: _buildFilledButton(
              context, 
              "قسط کیلکولیٹر", 
              Colors.blue, 
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InstallmentCalculaterPage()),
                );
              }
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildFilledButton(
              context, 
              "خرید و فروخت", 
              Colors.green, 
              () {
                // یہاں خرید و فروخت کا ڈائیلاگ پاپ اپ بالکل درست طریقے سے کھل جائے گا
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    insetPadding: const EdgeInsets.all(10),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.9,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close, color: Color(0xFFE53935)),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const Expanded(
                            child: SingleChildScrollView(
                              child: SalePurchaseForm(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilledButton(BuildContext context, String title, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}