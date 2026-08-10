import 'package:flutter/material.dart';
import 'customer_ledger_controller.dart';
import '../features/installment_plan_dialog.dart';

class LedgerTopWidget extends StatelessWidget {
  final CustomerLedgerController controller;

  const LedgerTopWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    bool isAdmin = controller.isAdmin;
    
    // کل بیلنس
    double totalBalance = controller.totalBalance;
    bool isPositive = totalBalance >= 0;
    Color balanceColor = isPositive ? Colors.green.shade700 : Colors.red.shade700;
    String balanceTypeLabel = isPositive ? "بقایا لینا / ایڈوانس" : "بقایا دینا ہے";

    // 🎯 لائیو شارٹ ڈیو کی رقم حاصل کرنا
    double totalShort = InstallmentPlanDialog.calculateTotalShort(controller.customerPhone);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 🟢 ۱۔ ہیڈر پٹی
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: const Color(0xFFE53935),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Center(
                  child: isAdmin
                      ? Text(
                          "${controller.customerName} ${controller.customerCast}".trim(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          "نایاب قسط پوائنٹ (${controller.customerName})",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                ),
              ),

              const SizedBox(width: 8),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  if (!isAdmin)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'logout') {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/',
                            (Route<dynamic> route) => false,
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text("لاگ آؤٹ", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 🎯 ۲۔ ہم سائز (Equal Height) 3D ابھرے ہوئے باکسز
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🟢 (الف) بایاں باکس: کل بیلنس
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: balanceColor.withValues(alpha: 0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: balanceColor.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Rs ${totalBalance.abs().toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.w800, 
                            color: balanceColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          balanceTypeLabel,
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.bold, 
                            color: balanceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // 🟢 (ب) دایاں باکس: 3D ایکشن چپ (اقساط کا پلان + کل شارٹ ڈیو)
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => InstallmentPlanDialog(
                            customerPhone: controller.customerPhone,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.indigo.shade300, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.shade200.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // بایاں حصہ: عنوان
                            Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "اقساط کا پلان",
                                    style: TextStyle(
                                      fontSize: 11, 
                                      fontWeight: FontWeight.w800, 
                                      color: Colors.indigo.shade900,
                                    ),
                                  ),
                                  const Text(
                                    "تفصیلات دیکھیں",
                                    style: TextStyle(
                                      fontSize: 8, 
                                      color: Colors.black54, 
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // عمودی ڈیوائیڈر
                            Container(
                              height: 28,
                              width: 1,
                              color: Colors.indigo.shade100,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                            ),

                            // دایاں حصہ: کل شارٹ ڈیو
                            Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Rs ${totalShort.toStringAsFixed(0)}",
                                    style: TextStyle(
                                      fontSize: 13, 
                                      fontWeight: FontWeight.w900, 
                                      color: totalShort > 0 ? Colors.red.shade800 : Colors.green.shade800,
                                    ),
                                  ),
                                  Text(
                                    totalShort > 0 ? "کل شارٹ" : "شارٹ نہیں",
                                    style: TextStyle(
                                      fontSize: 8, 
                                      fontWeight: FontWeight.bold, 
                                      color: totalShort > 0 ? Colors.red.shade800 : Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ۳۔ سمارٹ کیپسولز
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: isAdmin
              ? Row(
                  children: [
                    _buildActionCapsule(text: "رپورٹ", onTap: () {}),
                    const SizedBox(width: 6),
                    _buildActionCapsule(text: "تاریخ", onTap: () {}),
                    const SizedBox(width: 6),
                    _buildActionCapsule(text: "ریمائنڈر", onTap: () {}),
                    const SizedBox(width: 6),
                    _buildActionCapsule(text: "ایس ایم ایس", onTap: () {}),
                  ],
                )
              : Row(
                  children: [
                    _buildActionCapsule(
                      text: "قسط کیلکولیٹر",
                      onTap: () => controller.openInstallmentCalculator(context),
                      isCalculator: true,
                    ),
                  ],
                ),
        ),
        
        const SizedBox(height: 10),
        const Divider(color: Colors.black12, height: 1, thickness: 0.8),
      ],
    );
  }

  Widget _buildActionCapsule({
    required String text, 
    required VoidCallback onTap,
    bool isCalculator = false,
  }) {
    return Expanded(
      child: Material(
        color: isCalculator ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.black12,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: isCalculator ? Colors.blue.shade300 : Colors.black26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCalculator) ...[
                  Icon(Icons.calculate, size: 16, color: Colors.blue.shade800),
                  const SizedBox(width: 4),
                ],
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCalculator ? Colors.blue.shade800 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}