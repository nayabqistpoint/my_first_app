import 'package:flutter/material.dart';

class GuarantorInfoWidget extends StatelessWidget {
  final Map<String, dynamic> guarantorData;

  const GuarantorInfoWidget({
    super.key,
    required this.guarantorData,
  });

  @override
  Widget build(BuildContext context) {
    final String gName = guarantorData['name'] ?? 'ضامن کا نام موجود نہیں';
    final String gPhone = guarantorData['phone'] ?? 'فون نمبر موجود نہیں';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ضامن کی تفصیلات:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text("نام: $gName", style: const TextStyle(fontSize: 11, color: Colors.black87)),
          Text("فون نمبر: $gPhone", style: const TextStyle(fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
  }
}