import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> showAddPartyDialog(BuildContext context) async {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('نئی پارٹی شامل کریں', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'نام',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'موبائل نمبر',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('منسوخ', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
            onPressed: () async {
              String name = nameController.text.trim();
              String phone = phoneController.text.trim();

              if (name.isNotEmpty && phone.isNotEmpty) {
                // 🎯 اصل باکس کا نام: customerBox
                Box customerBox = Hive.box('customerBox');

                Map<String, dynamic> newCustomerData = {
                  'customerName': name,
                  'customerFatherName': null,
                  'customerCaste': null,
                  'customerPhone': phone,
                  'customerCnic': null,
                  'customerAddress': null,
                  'customerSelfie': null,
                  'isTermsAccepted': true,
                  'status': 'Approved',
                  'timestamp': DateTime.now().toIso8601String(),
                };

                // کی (Key) موبائل نمبر ہی بنے گی
                await customerBox.put(phone, newCustomerData);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('پارٹی کسٹمر باکس میں شامل ہو گئی')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('نام اور فون نمبر درج کریں')),
                );
              }
            },
            child: const Text('محفوظ کریں', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}