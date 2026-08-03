import 'package:flutter/material.dart';
import '../home_page/views/customers_list.dart';

void showAddPartyDialog(BuildContext context) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  showDialog(
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
            onPressed: () {
              String name = nameController.text.trim();
              String phone = phoneController.text.trim();

              if (name.isNotEmpty) {
                // کنٹرولر کے ذریعے زیرو بیلنس پارٹی سیو کی جا رہی ہے
                customerController.addManualCustomer(name: name, phone: phone);
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('پارٹی کامیابی سے شامل ہو گئی')),
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