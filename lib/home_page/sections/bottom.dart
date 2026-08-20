import 'package:flutter/material.dart';
// یہ پاتھ درست ہے: ایک بار ../ سے sections سے باہر، اور دوسرا ../ سے home_page سے باہر lib فولڈر تک
import 'package:my_first_app/installment_calculator_page.dart';
// خریداری فارم کا نیا پاتھ
import 'package:my_first_app/home_page/transaction_forms/purchase_page.dart';
// آپ کی نئی بنائی گئی ڈیٹا بیس فائل کا درست پاتھ
import 'package:my_first_app/database_page.dart';

class BottomSection extends StatelessWidget {
  const BottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        children: [
          // 1. پہلا بڑا کیپسول بٹن (قسط کیلکولیٹر)
          Expanded(
            flex: 4,
            child: _buildCapsuleButton(
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
          const SizedBox(width: 10),

          // 2. درمیان میں چھوٹا گول "پلس (+)" بٹن (ڈیٹا بیس کے لیے)
          FloatingActionButton(
            heroTag: "database_plus_btn",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DatabasePage()),
              );
            },
            backgroundColor: Colors.orange,
            elevation: 2,
            mini: true, // بٹن کو چھوٹا اور خوبصورت رکھنے کے لیے
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 10),

          // 3. دوسرا بڑا کیپسول بٹن (خریداری)
          Expanded(
            flex: 4,
            child: _buildCapsuleButton(
              context, 
              "خریداری", 
              Colors.green, 
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PurchasePage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // کیپسول ڈیزائن بنانے کا فنکشن (گول کونے)
  Widget _buildCapsuleButton(BuildContext context, String title, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // مکمل گول کیپسول شیپ
          ),
          elevation: 2,
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}