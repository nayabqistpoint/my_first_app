import 'package:flutter/material.dart';
import '../../database_page.dart';
import '../../installment_calculater_page.dart';
import '../transaction_forms/purchase_page.dart';

class BottomSection extends StatelessWidget {
  const BottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      child: Row(
        children: [
          // 1. قسط کیلکولیٹر
          Expanded(
            child: _buildActionBtn(
              title: "قسط کیلکولیٹر",
              color: Colors.blue,
              onTap: () => _navigateTo(context, const InstallmentCalculaterPage()),
            ),
          ),
          const SizedBox(width: 4),

          // 2. ڈیٹا بیس پلس بٹن (+)
          FloatingActionButton(
            heroTag: "database_plus_btn",
            onPressed: () => _navigateTo(context, const DatabasePage()),
            backgroundColor: Colors.orange,
            elevation: 1,
            mini: true,
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 4),

          // 3. خریداری
          Expanded(
            child: _buildActionBtn(
              title: "خریداری",
              color: Colors.green,
              onTap: () => _navigateTo(context, const PurchasePage()),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _buildActionBtn({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(38), // مناسب اور ہلکا سائز
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 1,
        padding: EdgeInsets.zero, // مکمل جگہ ٹیکسٹ کو دینے کے لیے
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            title,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}