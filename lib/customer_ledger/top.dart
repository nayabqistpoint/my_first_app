import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_first_app/customer_ledger/customer_ledger_controller.dart';
import 'package:my_first_app/customer_ledger/ledger_top_helper.dart';

class LedgerTopWidget extends StatelessWidget {
  final CustomerLedgerController controller;
  const LedgerTopWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = controller.isAdmin;
    final String phone = controller.customerPhone;
    final String title = LedgerTopHelper.getHeaderTitle(
      customer: controller.customer,
      customerData: controller.customerData,
      isAdmin: isAdmin,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🟢 ۱۔ ہیڈر پٹی
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: const Color(0xFFE53935),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: TextStyle(fontSize: isAdmin ? 18 : 16, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(radius: 16, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 20, color: Colors.white)),
              if (!isAdmin)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (v) => v == 'logout' ? Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false) : null,
                  itemBuilder: (_) => [const PopupMenuItem(value: 'logout', child: Text("لاگ آؤٹ"))],
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 🟢 ۲۔ لائیو بیلنس کارڈز
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: IntrinsicHeight(
            child: ValueListenableBuilder<Box>(
              valueListenable: Hive.box('transactionBox').listenable(),
              builder: (context, box, _) {
                final bData = LedgerTopHelper.getBalanceData(box, phone);
                final double totalShort = LedgerTopHelper.getShortAmount(phone);
                final Color bColor = bData['color'] as Color;

                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: LedgerTopHelper.boxDecoration(bColor, bColor.withValues(alpha: 0.15)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Rs ${bData['amount']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: bColor)),
                            Text(bData['label'].toString(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: bColor)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => LedgerTopHelper.openInstallmentDialog(context, phone, isAdmin),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                          decoration: LedgerTopHelper.boxDecoration(Colors.indigo.shade300, Colors.indigo.shade100),
                          child: Row(
                            children: [
                              _textCol("اقساط کا پلان", "تفصیلات دیکھیں", Colors.indigo.shade900, Colors.black54, 11, 8),
                              Container(height: 28, width: 1, color: Colors.indigo.shade100, margin: const EdgeInsets.symmetric(horizontal: 4)),
                              _textCol("Rs ${totalShort.toStringAsFixed(0)}", totalShort > 0 ? "کل شارٹ" : "شارٹ نہیں", totalShort > 0 ? Colors.red.shade800 : Colors.green.shade800, totalShort > 0 ? Colors.red.shade800 : Colors.green.shade800, 13, 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 🟢 ۳۔ کیپسولز
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: isAdmin
                ? [
                    _capsule("رپورٹ", () {}), const SizedBox(width: 6),
                    _capsule("تاریخ", () {}), const SizedBox(width: 6),
                    _capsule("ریمائنڈر", () {}), const SizedBox(width: 6),
                    _capsule("ایس ایم ایس", () {}),
                  ]
                : [
                    _capsule("قسط کیلکولیٹر", () => controller.openInstallmentCalculator(context), isCalc: true),
                  ],
          ),
        ),

        const SizedBox(height: 10),
        const Divider(color: Colors.black12, height: 1, thickness: 0.8),
      ],
    );
  }

  Widget _textCol(String t1, String t2, Color c1, Color c2, double s1, double s2) => Expanded(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(t1, style: TextStyle(fontSize: s1, fontWeight: FontWeight.w900, color: c1), maxLines: 1),
        Text(t2, style: TextStyle(fontSize: s2, fontWeight: FontWeight.bold, color: c2), maxLines: 1),
      ],
    ),
  );

  Widget _capsule(String text, VoidCallback onTap, {bool isCalc = false}) => Expanded(
    child: Material(
      color: isCalc ? Colors.blue.shade50 : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(border: Border.all(color: isCalc ? Colors.blue.shade300 : Colors.black26), borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCalc) ...[Icon(Icons.calculate, size: 16, color: Colors.blue.shade800), const SizedBox(width: 4)],
              Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isCalc ? Colors.blue.shade800 : Colors.black87)),
            ],
          ),
        ),
      ),
    ),
  );
}