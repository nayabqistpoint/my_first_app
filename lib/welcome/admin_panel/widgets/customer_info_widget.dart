import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CustomerInfoWidget extends StatelessWidget {
  final Map<String, dynamic> customerData;

  const CustomerInfoWidget({
    super.key,
    required this.customerData,
  });

  @override
  Widget build(BuildContext context) {
    final String phone = (customerData['customerPhone'] ?? customerData['phone'] ?? '').toString().trim();

    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('customerBox').listenable(),
      builder: (context, box, _) {
        final cust = box.values.firstWhere(
          (e) {
            if (e is Map) {
              final String custPhone = (e['customerPhone'] ?? e['phone'] ?? '').toString().trim();
              return custPhone.isNotEmpty && custPhone == phone;
            }
            return false;
          },
          orElse: () => customerData,
        );

        final String cnic = (cust['customerCnic'] ?? cust['cnic'] ?? 'CNIC موجود نہیں').toString().trim();
        final String address = (cust['customerAddress'] ?? cust['address'] ?? 'پتہ موجود نہیں').toString().trim();
        final String selfieBase64 = (cust['customerSelfie'] ?? cust['selfie'] ?? '').toString().trim();

        return Container(
          width: double.infinity,
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
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                ),
                child: selfieBase64.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: _buildSelfieImage(selfieBase64),
                      )
                    : const Icon(Icons.person, size: 45, color: Colors.grey),
              ),
              const SizedBox(width: 12),

              // 🎯 بائیں طرف کسٹمر کی تفصیلی معلومات
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "کسٹمر کی تفصیلی معلومات:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    Text("شناختی کارڈ: $cnic", style: const TextStyle(fontSize: 11, color: Colors.black87)),
                    const SizedBox(height: 2),
                    Text("پتہ: $address", style: const TextStyle(fontSize: 11, color: Colors.black87)),
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
      if (source.startsWith('http')) {
        return Image.network(source, fit: BoxFit.cover);
      }
      return Image.memory(base64Decode(source), fit: BoxFit.cover);
    } catch (_) {
      return const Icon(Icons.broken_image, color: Colors.grey);
    }
  }
}