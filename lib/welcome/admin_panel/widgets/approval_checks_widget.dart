import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ApprovalChecksWidget extends StatefulWidget {
  final Map<String, dynamic> requestData;
  final VoidCallback? onStateChanged;

  const ApprovalChecksWidget({
    super.key,
    required this.requestData,
    this.onStateChanged,
  });

  @override
  State<ApprovalChecksWidget> createState() => _ApprovalChecksWidgetState();
}

class _ApprovalChecksWidgetState extends State<ApprovalChecksWidget> {
  bool _isCnicVerified = false;
  bool _isAgreementSigned = false;

  void _completeOrder(String phone) {
    final customerBox = Hive.box('customerBox');
    final index = customerBox.values.toList().indexWhere(
      (e) => e is Map && ((e['customerPhone'] ?? e['phone'] ?? '').toString().trim() == phone),
    );

    if (index != -1) {
      var data = Map<String, dynamic>.from(customerBox.getAt(index));
      data['status'] = 'completed'; // مکمل سٹیٹس
      customerBox.putAt(index, data);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("موبائل کامیابی سے منتقل اور فعال کر دیا گیا ہے!", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade800,
        duration: const Duration(seconds: 2),
      ),
    );

    if (widget.onStateChanged != null) widget.onStateChanged!();
  }

  void _openSpecialPurchaseScreen(String phone) {
    // 🎯 پرچیز سکرین پر لے جانے کی لاجک
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("پرچیز سکرین کھولی جا رہی ہے...", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String phone = (widget.requestData['customerPhone'] ?? widget.requestData['phone'] ?? '').toString().trim();

    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('packageBox').listenable(),
      builder: (context, box, _) {
        final pkg = box.values.firstWhere(
          (e) => e is Map && ((e['customerPhone'] ?? e['phone'] ?? '').toString().trim() == phone),
          orElse: () => widget.requestData,
        );

        final rawImei = pkg['imei']?.toString().trim();
        final bool hasImei = rawImei != null && rawImei.isNotEmpty && rawImei != 'null' && rawImei != 'N/A';

        final bool canFinalize = _isCnicVerified && _isAgreementSigned;

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "منظور شدہ ریکویسٹ چیک لسٹ:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(height: 6),

              // 🎯 1. شناختی کارڈ اور دستاویزات کی تصدیق
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text("اصل شناختی کارڈ اور کاغذی کارروائی مکمل ہے", style: TextStyle(fontSize: 11)),
                value: _isCnicVerified,
                onChanged: (val) => setState(() => _isCnicVerified = val ?? false),
              ),

              // 🎯 2. ایگریمنٹ / اسٹام پیپر سائن
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text("اقساط ایگریمنٹ سائن ہو چکا ہے", style: TextStyle(fontSize: 11)),
                value: _isAgreementSigned,
                onChanged: (val) => setState(() => _isAgreementSigned = val ?? false),
              ),

              const SizedBox(height: 8),

              // 🎯 3. IMEI کی بنیاد پر دوہرا ایکشن (Two-Way Action)
              if (hasImei) ...[
                // صورتحال A: اگر IMEI پہلے سے موجود ہے
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canFinalize ? Colors.green.shade700 : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.verified, size: 16),
                    label: const Text("موبائل کسٹمر کو دیں / ایکٹیو کریں", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: canFinalize ? () => _completeOrder(phone) : null,
                  ),
                ),
              ] else ...[
                // صورتحال B: اگر IMEI نہیں ہے (N/A) -> مارکیٹ سے خریدیں
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.shopping_cart, size: 16),
                    label: const Text("موبائل مارکیٹ سے خریدیں (Special Order)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () => _openSpecialPurchaseScreen(phone),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}