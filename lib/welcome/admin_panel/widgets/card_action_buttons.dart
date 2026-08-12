import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CardActionButtons extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final dynamic request;
  final dynamic controller;
  final String? hiveKey;
  final bool? isPurchase;
  final TextEditingController? priceController;
  final VoidCallback? onStateChanged;

  const CardActionButtons({
    super.key,
    required this.requestData,
    this.request,
    this.controller,
    this.hiveKey,
    this.isPurchase,
    this.priceController,
    this.onStateChanged,
  });

  void _sendWhatsApp(String phone, String msg) async {
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.startsWith('0')) cleanPhone = '92${cleanPhone.substring(1)}';
    final Uri url = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent(msg)}");
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _processAction(BuildContext context, String phone, String status, String toastText, Color color, String msg) {
    // 1. ہائیو اپڈیٹ
    if (Hive.isBoxOpen('customerBox')) {
      final box = Hive.box('customerBox');
      final key = hiveKey ?? phone;
      if (box.containsKey(key)) {
        var d = Map<String, dynamic>.from(box.get(key));
        d['status'] = status;
        box.put(key, d);
      } else {
        final idx = box.values.toList().indexWhere((e) => e is Map && (e['customerPhone'] ?? e['phone'] ?? '').toString().trim() == phone);
        if (idx != -1) {
          var d = Map<String, dynamic>.from(box.getAt(idx));
          d['status'] = status;
          box.putAt(idx, d);
        }
      }
    }

    // 2. فوری سنیک بار
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(toastText, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(milliseconds: 1500),
      ),
    );

    // 3. لسٹ ریفریش
    if (onStateChanged != null) onStateChanged!();

    // 4. واٹس ایپ لانچ
    _sendWhatsApp(phone, msg);
  }

  @override
  Widget build(BuildContext context) {
    final String phone = (requestData['customerPhone'] ?? requestData['phone'] ?? '').toString().trim();
    
    bool isPurchaseRequested = false;
    if (Hive.isBoxOpen('packageBox')) {
      isPurchaseRequested = Hive.box('packageBox').values.any((e) => e is Map && (e['customerPhone'] ?? e['phone'] ?? '').toString().trim() == phone && e['isPurchaseRequested'] == true);
    }

    final String pass = phone.length >= 4 ? phone.substring(phone.length - 4) : '1234';

    return Row(
      children: [
        // 1. منظور / تصدیق کریں
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: Text(isPurchaseRequested ? "تصدیق کریں" : "سائن اپ منظور کریں", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            onPressed: () {
              if (isPurchaseRequested) {
                _processAction(context, phone, 'approved', "منظور شدہ میں منتقل ہو گیا!", Colors.green.shade800, "محترم کسٹمر! آپ کی درخواست ابتدائی طور پر منظور کر لی گئی ہے۔ اصل شناختی کارڈ اور ضروری کاغذات کے ساتھ تشریف لائیں۔");
              } else {
                _processAction(context, phone, 'completed', "سائن اپ منظور ہو گیا!", Colors.blue.shade800, "محترم کسٹمر! آپ کا سائن اپ منظور ہو گیا ہے۔\nیوزر نیم: $phone\nپاسورڈ: $pass");
              }
            },
          ),
        ),
        const SizedBox(width: 5),

        // 🎯 2. ریٹ مس میچ (صرف سائن اپ + پرچیز کی صورت میں دکھائیں)
        if (isPurchaseRequested) ...[
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
              icon: const Icon(Icons.edit_note, size: 16),
              label: const Text("ریٹ مس میچ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              onPressed: () {
                final newPrice = priceController?.text.trim() ?? '';
                _processAction(context, phone, 'rejected', "ریٹ مس میچ کے باعث مسترد!", Colors.orange.shade900, "محترم کسٹمر! قیمت مارکیٹ ریٹ سے موافقت نہیں رکھتی۔ RS: $newPrice تجدید کی گئی ہے۔");
              },
            ),
          ),
          const SizedBox(width: 5),
        ],

        // 3. مسترد کریں
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            icon: const Icon(Icons.cancel_outlined, size: 16),
            label: const Text("مسترد کریں", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            onPressed: () {
              _processAction(context, phone, 'rejected', "درخواست مسترد کر دی گئی!", Colors.red.shade800, "محترم کسٹمر! معذرت کے ساتھ آپ کی درخواست منظور نہیں کی جا سکی۔");
            },
          ),
        ),
      ],
    );
  }
}