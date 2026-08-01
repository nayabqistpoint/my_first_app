import 'package:flutter/material.dart';
import 'customer_ledger_controller.dart';

class LedgerTopWidget extends StatelessWidget {
  final CustomerLedgerController controller;

  const LedgerTopWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    bool isAdmin = controller.isAdmin;
    
    // کل بیلنس حاصل کر رہے ہیں
    double totalBalance = controller.totalBalance;
    
    // اگر بیلنس پلس میں ہے تو ریڈ (ادھار)، اگر مائنس میں ہے تو گرین (advance/ملی ہوئی رقم)
    bool isDebit = totalBalance >= 0;
    Color balanceColor = isDebit ? Colors.red : Colors.green;
    String balanceTypeLabel = isDebit ? "بقایا دینا ہے" : "بقایا لینا ہے / ایڈوانس";

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 🟢 ایپ بار / ہیڈر
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: const Color(0xFFE53935),
          child: Row(
            children: [
              // بیک بٹن
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),

              // سینٹرلائزڈ مواد (ایڈمن اور کسٹمر کے حساب سے)
              Expanded(
                child: Center(
                  child: isAdmin
                    ? Text(
                        // 1️⃣ ایڈمن ویو: صرف نام اور قوم، کوئی بریکٹ نہیں
                        "${controller.customerName} ${controller.customerCast}".trim(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        // 2️⃣ کسٹمر ویو: "نایاب قسط پوائنٹ" اور ساتھ چھوٹی گول بریکٹ میں نام
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

              // تصویر اور ساتھ لاگ آؤٹ کا پاپ اپ مینو (تین ڈاٹس)
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
                  
                  // کسٹمر ویو کے لیے لاگ آؤٹ کا پاپ اپ مینو (تین ڈاٹس)
                  if (!isAdmin)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'logout') {
                          // 🛡️ پرفیکٹ لاگ آؤٹ لاجک: تمام پچھلی اسکرینز ختم کر کے روٹ سکرین (پہلی سکرین) پر واپس لے جائے گا
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/', // یا آپ اپنی مین/لاگ ان روٹ کا نام یہاں دے سکتے ہیں
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

        const SizedBox(height: 10),

        // ۲۔ بیلنس باکس
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: balanceColor, width: 1.5),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Rs ${totalBalance.abs().toStringAsFixed(0)}",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: balanceColor),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: balanceColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    balanceTypeLabel,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: balanceColor),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

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

  // کیپسول ڈیزائن
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