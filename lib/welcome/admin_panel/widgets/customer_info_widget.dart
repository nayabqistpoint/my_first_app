import 'package:flutter/material.dart';

class CustomerInfoWidget extends StatelessWidget {
  final Map<String, dynamic> customerData;

  const CustomerInfoWidget({
    super.key,
    required this.customerData,
  });

  @override
  Widget build(BuildContext context) {
    final String cnic = customerData['cnic'] ?? 'CNIC موجود نہیں';
    final String address = customerData['address'] ?? 'پتہ موجود نہیں';

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
            "کسٹمر کی تفصیلات:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text("شناختی کارڈ: $cnic", style: const TextStyle(fontSize: 11, color: Colors.black87)),
          Text("پتہ: $address", style: const TextStyle(fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
  }
}