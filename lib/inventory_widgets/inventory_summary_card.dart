import 'package:flutter/material.dart';

class InventorySummaryCard extends StatelessWidget {
  final int totalInvestment; // کل مالیت باہر سے آئے گی
  final int totalItems; // کل آئٹمز کی تعداد باہر سے آئے گی

  const InventorySummaryCard({
    super.key,
    required this.totalInvestment,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // گہرا خوبصورت نیلا رنگ (Primary Deep Blue)
        color: const Color(0xFF1E3A8A), 
        borderRadius: BorderRadius.circular(16), // گول کونے
        boxShadow: [
          BoxShadow(
            // یہاں ہم نے 'withOpacity' کو بدل کر نئے طریقے 'withValues' سے لکھ دیا ہے
            // اس سے نئے فلٹر ورژنز میں کبھی بھی ایرر نہیں آئے گا
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4), // نیچے کی طرف ہلکا سایہ
          ),
        ],
      ),
      child: Row(
        children: [
          // ۱۔ بائیں طرف: کل سرمایہ کاری (Total Investment)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white70,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'کل سرمایہ کاری',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  // رقم کو خوبصورت فارمیٹ میں دکھانے کے لیے (جیسے 50,000)
                  'Rs. ${totalInvestment.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}', 
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // درمیان میں خوبصورت لکیر (Divider)
          Container(
            height: 40,
            width: 1,
            color: Colors.white24,
          ),

          // ۲۔ دائیں طرف: کل اسٹاک / آئٹمز (Total Items)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.white70,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'موجودہ اسٹاک',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalItems آئٹمز',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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