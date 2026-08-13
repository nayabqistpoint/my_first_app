import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class GuarantorInfoWidget extends StatelessWidget {
  final Map<String, dynamic> guarantorData;

  const GuarantorInfoWidget({super.key, required this.guarantorData});

  Future<void> _makeCall(String num) async {
    final uri = Uri(scheme: 'tel', path: num);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 کسٹمر کا فون نمبر صرف search key کے طور پر استعمال ہوگا
    final String custPhone = (guarantorData['customerPhone'] ?? guarantorData['phone'] ?? '').toString().trim();

    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('guarantorBox').listenable(),
      builder: (context, box, _) {
        dynamic gData = (custPhone.isNotEmpty && box.containsKey(custPhone)) ? box.get(custPhone) : null;

        gData ??= box.values.firstWhere(
          (e) => e is Map && ((e['customerPhone'] ?? e['phone'] ?? '').toString().trim() == custPhone),
          orElse: () => null,
        );

        if (gData is! Map || gData.isEmpty) return const SizedBox.shrink();

        // 🎯 اصل ضامن کا ڈیٹا (ضامن کی اپنی فیلڈز سے)
        final String gName = (gData['guarantorName'] ?? '').toString().trim();
        final String gFather = (gData['guarantorFatherName'] ?? '').toString().trim();
        final String gCaste = (gData['guarantorCaste'] ?? '').toString().trim();
        final String gPhone = (gData['guarantorPhone'] ?? '').toString().trim(); // 🎯 ضامن کا اپنا فون نمبر
        final String gCnic = (gData['guarantorCnic'] ?? 'CNIC موجود نہیں').toString().trim();
        final String rel = (gData['guarantorRelationship'] ?? '').toString().trim();
        final String addr = (gData['guarantorAddress'] ?? '').toString().trim();
        final String selfie = (gData['guarantorSelfie'] ?? '').toString().trim();

        if (gName.isEmpty && gPhone.isEmpty) return const SizedBox.shrink();

        List<String> extra = [];
        if (gFather.isNotEmpty) extra.add("ولد: $gFather");
        if (gCaste.isNotEmpty) extra.add("قوم: $gCaste");
        final nameHeader = gName + (extra.isNotEmpty ? " (${extra.join(' - ')})" : "");

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎯 دائیں طرف ضامن کی اپنی چورس سیلفی
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: selfie.isNotEmpty
                    ? ClipRRect(borderRadius: BorderRadius.circular(5), child: _buildSelfieImage(selfie))
                    : const Icon(Icons.person, size: 45, color: Colors.grey),
              ),
              const SizedBox(width: 12),

              // 🎯 بائیں طرف ضامن کی اپنی معلومات
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ضامن کی تفصیلی معلومات:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(nameHeader, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    
                    // 📞 ضامن کا اپنا فون نمبر ڈائریکٹ کال کے لیے
                    if (gPhone.isNotEmpty)
                      InkWell(
                        onTap: () => _makeCall(gPhone),
                        child: Text(
                          "فون نمبر: $gPhone",
                          style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                        ),
                      ),
                    
                    Text("شناختی کارڈ: $gCnic", style: const TextStyle(fontSize: 11)),
                    if (rel.isNotEmpty) Text("رشتہ: $rel", style: const TextStyle(fontSize: 11)),
                    if (addr.isNotEmpty) Text("پتہ: $addr", style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelfieImage(String source) {
    try {
      return source.startsWith('http')
          ? Image.network(source, fit: BoxFit.cover)
          : Image.memory(base64Decode(source), fit: BoxFit.cover);
    } catch (_) {
      return const Icon(Icons.broken_image, color: Colors.grey);
    }
  }
}