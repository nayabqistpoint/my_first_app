import 'package:flutter/material.dart';
import '../../../../home_page/transaction_forms/sale_page.dart';

class CardActionButtons extends StatelessWidget {
  final dynamic controller;
  final dynamic hiveKey;
  final bool isPurchase;
  final Map<String, dynamic> request;

  const CardActionButtons({
    super.key,
    required this.controller,
    required this.hiveKey,
    required this.isPurchase,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    String status = request['status']?.toString().toLowerCase() ?? 'pending';
    var keyToUse = request['hiveKey'] ?? hiveKey;

    // اگر ریکوئسٹ نہ پینڈنگ ہے اور نہ ہی اپرووڈ، تو بٹن چھپا دیں
    if (status != 'pending' && status != 'approved') {
      return const SizedBox.shrink();
    }

    // اگر ریکوئسٹ 'approved' (منظور شدہ) ہے تو صرف 2 بٹن دکھائیں
    if (status == 'approved') {
      return Row(
        children: [
          // 1. رد کریں (Reject)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                if (keyToUse != null) {
                  controller.rejectTransaction(keyToUse);
                }
              },
              icon: const Icon(Icons.close, color: Colors.red, size: 16),
              label: const Text("رد کریں", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 2. خریداری جاری رکھیں / سیل پیج پر جائیں اور واپس آ کر مکمل کریں
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                if (keyToUse != null) {
                  // سیلز پیج پر جائیں
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SalePage(),
                    ),
                  );

                  // جب سیلز پیج سے واپس آئیں تو ٹرانزیکشن کو مکمل کر دیں
                  await controller.assignUsernameAndComplete(keyToUse);
                }
              },
              icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 16),
              label: const Text("خریداری جاری رکھیں", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 2),
              ),
            ),
          ),
        ],
      );
    }

    // اگر پینڈنگ ہے تو پرانے چاروں بٹن دکھائیں
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  controller.callForVerification(request);
                },
                icon: const Icon(Icons.chat, color: Colors.teal, size: 16),
                label: const Text("1. تصدیق کے لیے", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 10)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.teal),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  if (keyToUse != null) {
                    controller.rejectTransaction(keyToUse);
                  }
                },
                icon: const Icon(Icons.close, color: Colors.red, size: 16),
                label: const Text("4. رد کریں", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (keyToUse != null) {
                    controller.approveTransaction(keyToUse);
                  }
                },
                icon: const Icon(Icons.check, color: Colors.white, size: 16),
                label: const Text("2. منظور کریں", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (keyToUse != null) {
                    controller.assignUsernameAndComplete(keyToUse);
                  }
                },
                icon: const Icon(Icons.verified_user, color: Colors.white, size: 16),
                label: const Text("3. یوزر نیم اسائن", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}