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

  // 🎯 واٹس ایپ بھیجنے کا بغیر رکے (Non-blocking) فنکشن
  void _launchWhatsApp(String phone, String message) {
    Future.microtask(() async {
      String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      if (cleanPhone.startsWith('0')) {
        cleanPhone = '92${cleanPhone.substring(1)}';
      }

      final Uri url = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}");
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    });
  }

  // 🎯 فوری UI اپڈیٹ اور پاپ اپ ڈسپلے
  void _executeAction(BuildContext context, String phone, String newStatus, String popMessage, Color bgColor, String whatsappMsg) {
    // 1. ہائیو باکس اپڈیٹ
    final customerBox = Hive.box('customerBox');
    final keyToUpdate = hiveKey ?? phone;

    if (customerBox.containsKey(keyToUpdate)) {
      var data = Map<String, dynamic>.from(customerBox.get(keyToUpdate));
      data['status'] = newStatus;
      customerBox.put(keyToUpdate, data);
    } else {
      final index = customerBox.values.toList().indexWhere(
        (e) => e is Map && ((e['customerPhone'] ?? e['phone'] ?? '').toString().trim() == phone),
      );
      if (index != -1) {
        var data = Map<String, dynamic>.from(customerBox.getAt(index));
        data['status'] = newStatus;
        customerBox.putAt(index, data);
      }
    }

    // 2. فوری سنیک بار پاپ اپ (ایکشن سے پہلے ہی دکھائیں)
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              newStatus == 'approved' ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                popMessage,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    // 3. فوراً لسٹ سے غائب کریں
    if (onStateChanged != null) onStateChanged!();

    // 4. بیک گراؤنڈ میں واٹس ایپ کھولیں
    _launchWhatsApp(phone, whatsappMsg);
  }

  @override
  Widget build(BuildContext context) {
    final String phone = (requestData['customerPhone'] ?? requestData['phone'] ?? '').toString().trim();

    return Row(
      children: [
        // 1. 🎯 تصدیق کریں
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: const Text("تصدیق کریں", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            onPressed: () {
              const msg = "محترم کسٹمر! آپ کی درخواست ابتدائی طور پر منظور کر لی گئی ہے۔ برائے مہربانی اپنے اصل شناختی کارڈ، ضمانتی کاغذات اور وصولی کے لیے دکان پر تشریف لائیں۔ شکریہ!";
              _executeAction(
                context, 
                phone, 
                'approved', 
                "درخواست کامیابی سے منظور شدہ میں منتقل ہو گئی!", 
                Colors.green.shade800,
                msg
              );
            },
          ),
        ),
        const SizedBox(width: 6),

        // 2. 🎯 ریٹ مس میچ
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.edit_note, size: 16),
            label: const Text("ریٹ مس میچ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            onPressed: () {
              final newPrice = priceController?.text.trim() ?? '';
              final msg = "محترم کسٹمر! آپ کی درخواست میں موبائل کی قیمت مارکیٹ ریٹ سے موافقت نہیں رکھتی۔ ہم نے آپ کے ماڈل کی قیمت RS: $newPrice تجدید کی ہے۔ برائے مہربانی ایپ پر جا کر اس قیمت کے ساتھ دوبارہ درخواست دیں۔";
              _executeAction(
                context, 
                phone, 
                'rejected', 
                "درخواست ریٹ مس میچ کے باعث مسترد کر دی گئی!", 
                Colors.orange.shade900,
                msg
              );
            },
          ),
        ),
        const SizedBox(width: 6),

        // 3. 🎯 مسترد کریں
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.cancel_outlined, size: 16),
            label: const Text("مسترد کریں", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            onPressed: () {
              const msg = "محترم کسٹمر! معذرت کے ساتھ آپ کی درخواست منظور نہیں کی جا سکی۔ مزید معلومات کے لیے دکان سے رابطہ کریں۔";
              _executeAction(
                context, 
                phone, 
                'rejected', 
                "درخواست مسترد کر دی گئی!", 
                Colors.red.shade800,
                msg
              );
            },
          ),
        ),
      ],
    );
  }
}