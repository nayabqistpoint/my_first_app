import 'package:flutter/material.dart';
import '../../installment_calculater_page.dart'; 
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
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildFilledButton(
              context, 
              "خرید و فروخت", 
              Colors.green, 
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SalePurchaseScreen()),
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