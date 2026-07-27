import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('نیا اکاؤنٹ بنائیں', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.red[800],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.red.shade200, width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Icon(Icons.person_add_alt_1, size: 40, color: Colors.red[800]),
                ),
                const SizedBox(height: 10),
                Text(
                  'کسٹمر رجسٹریشن فارم',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[800]),
                ),
                const SizedBox(height: 20),
                
                // نام فیلڈ
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'पूरा نام (Full Name)',
                    prefixIcon: Icon(Icons.person, color: Colors.red[800]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),

                // فون نمبر فیلڈ
              TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'موبائل نمبر (Phone Number)',
                    prefixIcon: Icon(Icons.phone, color: Colors.red[800]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),

                // شناختی کارڈ فیلڈ
                TextField(
                  controller: _cnicController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'شناختی کارڈ نمبر (CNIC)',
                    prefixIcon: Icon(Icons.credit_card, color: Colors.red[800]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),

                // ایڈریس فیلڈ
                TextField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'مکمل پتہ (Address)',
                    prefixIcon: Icon(Icons.home, color: Colors.red[800]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),

                // سائن اپ بٹن
                ElevatedButton(
                  onPressed: () {
                    // یہاں بعد میں سائن اپ کی لاجک آئے گی
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('اکاؤنٹ رجسٹر کریں'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}