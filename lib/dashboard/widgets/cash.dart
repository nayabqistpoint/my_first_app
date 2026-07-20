import 'package:flutter/material.dart';

class CashWidget extends StatelessWidget {
  const CashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Column(
        children: [
          // Row: Cash in Hand اور Bank Balance کے کارڈز (بڑے فونٹ کے ساتھ)
          Row(
            children: [
              // 1. Cash in Hand
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade300, width: 1.2),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Cash: ", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text("Rs. 800", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)), // فونٹ بڑا کر دیا
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // 2. Bank Balance
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade300, width: 1.2),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Bank: ", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text("Rs. 12,500", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)), // فونٹ بڑا کر دیا
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),

          // Banks List ہیڈر
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.red, size: 26),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {},
              ),
              const Text("Banks List", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 4),

          // بینک لسٹ
          Container(
            height: 170,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: 12,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Rs. 2,500", 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            "Bank Account ${index + 1}",
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    if (index < 11) const Divider(color: Colors.black12, height: 1),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}