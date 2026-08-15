import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'customer_ledger_controller.dart';
import 'ledger_top_helper.dart';

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 🟢 ۱۔ ہیڈر پٹی (ایڈمن اور کسٹمر دونوں موڈز کے لیے)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: const Color(0xFFE53935),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: isAdmin ? 18 : 16, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                child: const CircleAvatar(radius: 16, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 20, color: Colors.white)),
              ),
              if (!isAdmin)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (val) => val == 'logout' ? Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false) : null,
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout, color: Colors.red, size: 20), SizedBox(width: 8), Text("لاگ آؤٹ")])),
                  ],
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 🟢 ۲۔ لائیو بیلنس اور شارٹ ڈیو باکسز
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // کل بیلنس
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: bColor.withValues(alpha: 0.3), width: 1.5),
                          boxShadow: [BoxShadow(color: bColor.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Rs ${bData['amount']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: bColor)),
                            const SizedBox(height: 2),
                            Text(bData['label'].toString(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: bColor)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // اقساط کا پلان + کل شارٹ ڈیو
                    Expanded(
                      child: InkWell(
                        onTap: () => LedgerTopHelper.openInstallmentDialog(context, phone, isAdmin),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.indigo.shade300, width: 1.5),
                            boxShadow: [BoxShadow(color: Colors.indigo.shade200.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("اقساط کا پلان", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))),
                                    Text("تفصیلات دیکھیں", style: TextStyle(fontSize: 8, color: Colors.black54, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Container(height: 28, width: 1, color: Colors.indigo.shade100, margin: const EdgeInsets.symmetric(horizontal: 4)),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Rs ${totalShort.toStringAsFixed(0)}", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: totalShort > 0 ? Colors.red.shade800 : Colors.green.shade800)),
                                    Text(totalShort > 0 ? "کل شارٹ" : "شارٹ نہیں", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: totalShort > 0 ? Colors.red.shade800 : Colors.green.shade800)),
                                  ],
                                ),
                              ),
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

        // 🟢 ۳۔ ایکشن کیپسولز
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: isAdmin
              ? Row(
                  children: [
                    _buildCapsule("رپورٹ", () {}), const SizedBox(width: 6),
                    _buildCapsule("تاریخ", () {}), const SizedBox(width: 6),
                    _buildCapsule("ریمائنڈر", () {}), const SizedBox(width: 6),
                    _buildCapsule("ایس ایم ایس", () {}),
                  ],
                )
              : Row(
                  children: [
                    _buildCapsule("قسط کیلکولیٹر", () => controller.openInstallmentCalculator(context), isCalc: true),
                  ],
                ),
        ),

        const SizedBox(height: 10),
        const Divider(color: Colors.black12, height: 1, thickness: 0.8),
      ],
    );
  }

  Widget _buildCapsule(String text, VoidCallback onTap, {bool isCalc = false}) {
    return Expanded(
      child: Material(
        color: isCalc ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: isCalc ? Colors.blue.shade300 : Colors.black26),
              borderRadius: BorderRadius.circular(20),
            ),
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
}