import 'package:flutter/material.dart';

class ProfitLossWidget extends StatelessWidget {
  const ProfitLossWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          // 1. Other Income Card (بڑے اور واضح فونٹ کے ساتھ)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade400, width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Other Income: ",
                    style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    "Rs. 1,200",
                    style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 18), // فونٹ بڑا کر دیا
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // 2. Profit/Loss Card (Profit گرین اور Loss ریڈ کے ساتھ)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade400, width: 1.2), 
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profit (Green) / Loss (Red) اسمارٹ ٹیکسٹ
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      children: [
                        TextSpan(text: "Profit", style: TextStyle(color: Colors.green.shade700)),
                        const TextSpan(text: "/", style: TextStyle(color: Colors.black87)),
                        const TextSpan(text: "Loss: ", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  Text(
                    "Rs. 5,200",
                    style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 18), // فونٹ بڑا کر دیا
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}