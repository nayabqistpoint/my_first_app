import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ImeiControllerWidget extends StatefulWidget {
  final Map<String, dynamic> requestData;
  final String phone;
  final VoidCallback onNavigateToPurchase;

  const ImeiControllerWidget({
    super.key,
    required this.requestData,
    required this.phone,
    required this.onNavigateToPurchase,
  });

  @override
  State<ImeiControllerWidget> createState() => _ImeiControllerWidgetState();
}

class _ImeiControllerWidgetState extends State<ImeiControllerWidget> {
  bool _isAdvanceConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('packageBox').listenable(),
      builder: (context, box, _) {
        final pkg = box.values.firstWhere(
          (e) => e is Map && ((e['customerPhone'] ?? e['phone'] ?? '').toString().trim() == widget.phone),
          orElse: () => null,
        );

        final String imei = (pkg?['imei'] ?? 'N/A').toString().trim();
        final bool hasImei = imei.isNotEmpty && imei != 'N/A' && imei != 'null';

        if (hasImei) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.indigo.shade50],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.indigo.shade100, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withValues(alpha: 0.08), // 🎯 withOpacity کی جگہ withValues استعمال ہوا ہے
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 18, color: Colors.indigo.shade800),
                  const SizedBox(width: 6),
                  Text(
                    "موبائل خریداری کا عمل:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7), // 🎯 withOpacity کی جگہ withValues استعمال ہوا ہے
                  borderRadius: BorderRadius.circular(6),
                ),
                child: CheckboxListTile(
                  dense: true,
                  activeColor: Colors.indigo.shade700,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: const Text(
                    "شناختی کارڈ تصدیق شدہ اور ایڈوانس وصول ہو گیا",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  value: _isAdvanceConfirmed,
                  onChanged: (val) => setState(() => _isAdvanceConfirmed = val ?? false),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAdvanceConfirmed ? Colors.indigo.shade700 : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    elevation: _isAdvanceConfirmed ? 4 : 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.shopping_cart_checkout, size: 16),
                  label: const Text(
                    "موبائل مارکیٹ سے خریدیں (Special Order)",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isAdvanceConfirmed ? widget.onNavigateToPurchase : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}