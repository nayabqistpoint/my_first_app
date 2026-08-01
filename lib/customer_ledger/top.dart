import 'package:flutter/material.dart';
import 'customer_ledger_controller.dart';

class LedgerTopWidget extends StatelessWidget {
  final CustomerLedgerController controller;

  const LedgerTopWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    bool isAdmin = controller.isAdmin;
    
    // کل بیلنس حاصل کر رہے ہیں (جو کنٹرولر سے آ رہا ہے)
    double totalBalance = controller.totalBalance;
    
    // اگر بیلنس پلس میں ہے تو ریڈ (ادھار)، اگر مائنس میں ہے تو گرین (advance/ملی ہوئی رقم)
    bool isDebit = totalBalance >= 0;
    Color balanceColor = isDebit ? Colors.red : Colors.green;
    String balanceTypeLabel = isDebit ? "بقایا دینا ہے" : "بقایا لینا ہے / ایڈوانس";

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ۱۔ ہیڈر (رول بیسڈ: ایڈمن کے لیے نام + قوم، کسٹمر کے لیے بائیں طرف نایاب قسط پوائنٹ اور دائیں طرف نام)
        Container(
          color: const Color(0xFFE53935),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                // بیک ایرو
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 12),
                
                // رول کے لحاظ سے ہیڈر کا ٹائٹل اور نام (اوور فلو سے بچنے کے لیے Expanded کا استعمال)
                Expanded(
                  child: isAdmin
                      ? // ایڈمن کے لیے: کسٹمر کا نام اور قوم
                        Text(
                          "${controller.customerName} ${controller.customerCast}".trim(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        )
                      : // کسٹمر کے لیے: بائیں طرف 'نایاب قسط پوائنٹ' اور دائیں طرف صرف کسٹمر کا نام
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "نایاب قسط پوائنٹ",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
                            ),
                            Flexible(
                              child: Text(
                                controller.customerName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(width: 8),
                // بڑا پروفائل آئکن
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white24, 
                  child: Icon(Icons.person, color: Colors.white, size: 25),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ۲۔ بیلنس باکس (رنگ اور حساب اب نیچے کے رننگ بیلنس کے بالکل مطابق ہو گا)
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

        // ۳۔ سمارٹ کیپسولز (رول بیسڈ: ایڈمن کے لیے پرانے چار، کسٹمر کے لیے قسط کیلکولیٹر)
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