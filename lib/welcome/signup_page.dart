import 'package:flutter/material.dart';

import 'signup/customer_info.dart';
import 'signup/guarantor_info.dart';
import 'signup/item_package_ui.dart';
import 'signup/terms_block.dart';
import 'signup/signup_controller.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final SignUpController _controller = SignUpController();

  void _handleSubmission() async {
    bool success = await _controller.submitRegistration(context, _formKey);
    if (success && mounted) {
      Navigator.pop(context);
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
      // ListenableBuilder کے ذریعے بٹن خود بخود کنٹرولر کی اسٹیٹ کے مطابق اپڈیٹ ہوگا
      bottomNavigationBar: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: ElevatedButton(
              onPressed: _controller.isTermsAccepted ? _handleSubmission : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                disabledBackgroundColor: Colors.grey.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('رجسٹریشن محفوظ کریں', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          );
        },
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

            CustomerInfoWidget(key: _controller.customerKey),
            const SizedBox(height: 16),

            GuarantorInfoWidget(key: _controller.guarantorKey),
            const SizedBox(height: 16),

            ItemPackageUI(key: _controller.packageKey),
            const SizedBox(height: 16),

            TermsBlock(
              onTermsChanged: (isAccepted) {
                _controller.updateTerms(isAccepted);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}