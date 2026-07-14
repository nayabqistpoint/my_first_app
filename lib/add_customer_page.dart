import 'package:flutter/material.dart';

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({super.key});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _balanceController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نیا کسٹمر شامل کریں', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF0D47A1),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'کسٹمر کی بنیادی معلومات درج کریں:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                ),
                const SizedBox(height: 16),
                
                // نام
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'کسٹمر کا نام',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'براہ کرم کسٹمر کا نام درج کریں';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // فون نمبر
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'موبائل نمبر',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'براہ کرم فون نمبر درج کریں';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ابتدائی ادھار/بیلنس
                TextFormField(
                  controller: _balanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ابتدائی بیلنس / ادھار رقم (Rs.)',
                    prefixIcon: Icon(Icons.money),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'براہ کرم رقم درج کریں (زیرو بھی لکھ سکتے ہیں)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // وعدے کی تاریخ
                TextFormField(
                  controller: _dueDateController,
                  decoration: const InputDecoration(
                    labelText: 'قسط / وعدے کی تاریخ (مثلاً: 15 Jul 26)',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'براہ کرم وعدے کی تاریخ درج کریں';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // محفوظ کرنے کا بٹن
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // نیا کسٹمر ڈیٹا واپس ہوم پیج پر بھیجنا
                        final newCustomer = {
                          'name': _nameController.text.trim(),
                          'phone': _phoneController.text.trim(),
                          'balance': int.tryParse(_balanceController.text.trim()) ?? 0,
                          'dueDate': _dueDateController.text.trim(),
                          'entries': []
                        };
                        Navigator.pop(context, newCustomer);
                      }
                    },
                    child: const Text(
                      'کسٹمر محفوظ کریں',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}