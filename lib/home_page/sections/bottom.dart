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
                // اب یہ قسط کیلکولیٹر کی طرح بالکل فل سکرین پیج کے طور پر کھلے گا
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SalePurchaseForm()),
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