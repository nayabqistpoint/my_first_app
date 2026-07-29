import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'signup/customer_info.dart';
import 'signup/guarantor_info.dart';
import 'signup/item_package_ui.dart'; // نئی فائل امپورٹ کی

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  // تینوں خود مختار وجٹس کی کیز (Keys)
  final GlobalKey<CustomerInfoWidgetState> _customerKey = GlobalKey<CustomerInfoWidgetState>();
  final GlobalKey<GuarantorInfoWidgetState> _guarantorKey = GlobalKey<GuarantorInfoWidgetState>();
  final GlobalKey<ItemPackageUIState> _packageKey = GlobalKey<ItemPackageUIState>(); // پیکج کی Key

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      // تینوں فائلوں سے ان کا اپنا اپنا ڈیٹا منگوا لیا
      var customerData = _customerKey.currentState?.getCustomerData() ?? {};
      var guarantorData = _guarantorKey.currentState?.getGuarantorData() ?? {};
      var packageData = _packageKey.currentState?.getPackageData() ?? {}; // پیکج کا ڈیٹا

      var customerBox = Hive.box('customerBox');

      Map<String, dynamic> requestData = {
        ...customerData,
        ...guarantorData,
        ...packageData, // پیکج کا ڈیٹا بھی شامل کر دیا
        'status': 'Pending',
        'timestamp': DateTime.now().toString(),
      };

      await customerBox.add(requestData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رجسٹریشن کامیابی سے محفوظ ہو گئی ہے')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        elevation: 2,
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('نیا کسٹمر رجسٹریشن فارم', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            Text('نایاب قسط پوائنٹ', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: _submitData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('رجسٹریشن محفوظ کریں', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'نوٹ: ہر ٹرانزیکشن کے لیے اسٹامپ و پرا نوٹ لازمی ہے',
                  style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 1. کسٹمر انفو
            CustomerInfoWidget(key: _customerKey),
            const SizedBox(height: 16),

            // 2. ضامن انفو
            GuarantorInfoWidget(key: _guarantorKey),
            const SizedBox(height: 16),

            // 3. آئٹم اور پیکج انفو (بالکل نئی اور خود مختار فائل)
            ItemPackageUI(key: _packageKey),
          ],
        ),
      ),
    );
  }
}