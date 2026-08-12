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
    final String phone = (guarantorData['customerPhone'] ?? guarantorData['phone'] ?? '').toString().trim();

    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('guarantorBox').listenable(),
      builder: (context, box, _) {
        dynamic gData = (phone.isNotEmpty && box.containsKey(phone)) ? box.get(phone) : null;
        
        gData ??= box.values.firstWhere(
          (e) => e is Map && ((e['customerPhone'] ?? e['phone'] ?? '').toString().trim() == phone),
          orElse: () => null,
        );

        gData ??= guarantorData;

        if (gData is! Map || gData.isEmpty) return const SizedBox.shrink();

        final String name = (gData['guarantorName'] ?? gData['name'] ?? '').toString().trim();
        final String father = (gData['guarantorFatherName'] ?? gData['fatherName'] ?? '').toString().trim();
        final String caste = (gData['guarantorCaste'] ?? gData['caste'] ?? '').toString().trim();
        final String gPhone = (gData['guarantorPhone'] ?? gData['phone'] ?? '').toString().trim();
        final String cnic = (gData['guarantorCnic'] ?? gData['cnic'] ?? 'CNIC موجود نہیں').toString().trim();
        final String rel = (gData['guarantorRelationship'] ?? gData['relationship'] ?? '').toString().trim();
        final String addr = (gData['guarantorAddress'] ?? gData['address'] ?? '').toString().trim();
        final String selfie = (gData['guarantorSelfie'] ?? gData['selfie'] ?? '').toString().trim();

        if (name.isEmpty && gPhone.isEmpty) return const SizedBox.shrink();

        List<String> extra = [];
        if (father.isNotEmpty) extra.add("ولد: $father");
        if (caste.isNotEmpty) extra.add("قوم: $caste");
        final nameHeader = name + (extra.isNotEmpty ? " (${extra.join(' - ')})" : "");

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
              // 🎯 دائیں طرف چورس سیلفی تصویر
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: selfie.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: _buildSelfieImage(selfie),
                      )
                    : const Icon(Icons.person, size: 45, color: Colors.grey),
              ),
              const SizedBox(width: 12),

              // 🎯 بائیں طرف معلومات
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ضامن کی تفصیلی معلومات:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(nameHeader, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    
                    // 📞 ہائپر لنک فون نمبر ڈائریکٹ کال کے لیے
                    if (gPhone.isNotEmpty)
                      InkWell(
                        onTap: () => _makeCall(gPhone),
                        child: Text(
                          "فون نمبر: $gPhone",
                          style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                        ),
                      ),
                    
                    Text("شناختی کارڈ: $cnic", style: const TextStyle(fontSize: 11)),
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