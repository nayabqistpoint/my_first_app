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
    final String cleanPhone = phone.trim();
    final String targetKey = hiveKey ?? cleanPhone;

    // 🎯 1. packageBox میں اسٹیٹس اپڈیٹ کرنا (مرکزی فلٹر باکس)
    if (Hive.isBoxOpen('packageBox')) {
      final pBox = Hive.box('packageBox');
      if (pBox.containsKey(targetKey)) {
        var d = Map<String, dynamic>.from(pBox.get(targetKey));
        d['status'] = status;
        pBox.put(targetKey, d);
      } else {
        for (var key in pBox.keys) {
          final val = pBox.get(key);
          if (val is Map && (val['customerPhone'] ?? val['phone'] ?? '').toString().trim() == cleanPhone) {
            var d = Map<String, dynamic>.from(val);
            d['status'] = status;
            pBox.put(key, d);
            break;
          }
        }
      }
    }

    // 🎯 2. customerBox میں بھی اسٹیٹس اپڈیٹ رکھنا
    if (Hive.isBoxOpen('customerBox')) {
      final cBox = Hive.box('customerBox');
      if (cBox.containsKey(targetKey)) {
        var d = Map<String, dynamic>.from(cBox.get(targetKey));
        d['status'] = status;
        cBox.put(targetKey, d);
      } else {
        for (var key in cBox.keys) {
          final val = cBox.get(key);
          if (val is Map && (val['customerPhone'] ?? val['phone'] ?? '').toString().trim() == cleanPhone) {
            var d = Map<String, dynamic>.from(val);
            d['status'] = status;
            cBox.put(key, d);
            break;
          }
        }
      }
    }

    // 3. سنیک بار دکھانا
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(toastText, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(milliseconds: 1500),
      ),
    );

    // 4. لسٹ کی حالت ریفریش کرنا
    if (onStateChanged != null) onStateChanged!();

    // 5. واٹس ایپ میسج بھیجنا
    _sendWhatsApp(cleanPhone, msg);
  }

  @override
  Widget build(BuildContext context) {
    final String phone = (requestData['customerPhone'] ?? requestData['phone'] ?? '').toString().trim();
    
    bool isPurchaseRequested = false;
    if (Hive.isBoxOpen('packageBox')) {
      isPurchaseRequested = Hive.box('packageBox').values.any((e) => 
        e is Map && 
        (e['customerPhone'] ?? e['phone'] ?? '').toString().trim() == phone && 
        e['isPurchaseRequested'] == true
      );
    }

    final String pass = phone.length >= 4 ? phone.substring(phone.length - 4) : '1234';

    return Row(
      children: [
        // 1. منظور / تصدیق کریں
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: Text(
              isPurchaseRequested ? "تصدیق کریں" : "سائن اپ منظور کریں", 
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)
            ),
            onPressed: () {
              if (isPurchaseRequested) {
                // پرچیز کے ساتھ ریکویسٹ -> 'Approved' اسٹیٹس (منظور شدہ ویو میں جائے گا)
                _processAction(
                  context, 
                  phone, 
                  'Approved', 
                  "منظور شدہ میں منتقل ہو گیا!", 
                  Colors.green.shade800, 
                  "محترم کسٹمر! آپ کی درخواست ابتدائی طور پر منظور کر لی گئی ہے۔ اصل شناختی کارڈ اور ضروری کاغذات کے ساتھ تشریف لائیں۔"
                );
              } else {
                // صرف سائن اپ ریکویسٹ -> 'Completed' اسٹیٹس
                _processAction(
                  context, 
                  phone, 
                  'Completed', 
                  "سائن اپ منظور ہو گیا!", 
                  Colors.blue.shade800, 
                  "محترم کسٹمر! آپ کا سائن اپ منظور ہو گیا ہے۔\nیوزر نیم: $phone\nپاسورڈ: $pass"
                );
              }
            },
          ),
        ),
        const SizedBox(width: 5),

        // 🎯 2. ریٹ مس میچ (صرف سائن اپ + پرچیز موڈ میں دکھائیں)
        if (isPurchaseRequested) ...[
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
              icon: const Icon(Icons.edit_note, size: 16),
              label: const Text("ریٹ مس میچ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              onPressed: () {
                final newPrice = priceController?.text.trim() ?? '';
                _processAction(
                  context, 
                  phone, 
                  'Rejected', 
                  "ریٹ مس میچ کے باعث مسترد!", 
                  Colors.orange.shade900, 
                  "محترم کسٹمر! قیمت مارکیٹ ریٹ سے موافقت نہیں رکھتی۔ RS: $newPrice تجدید کی گئی ہے۔"
                );
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
              _processAction(
                context, 
                phone, 
                'Rejected', 
                "درخواست مسترد کر دی گئی!", 
                Colors.red.shade800, 
                "محترم کسٹمر! معذرت کے ساتھ آپ کی درخواست منظور نہیں کی جا سکی۔"
              );
            },
          ),
        ),
      ],
    );
  }
}