import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../installment_calculater_page.dart';
import 'signup_page.dart';
import '../home_page.dart'; // آپ کے ہوم پیج کا امپورٹ

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isCustomerLogin = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // فنگر پرنٹ کے لیے انسٹینس
  final LocalAuthentication auth = LocalAuthentication();

  void _handleLogin() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('براہ کرم یوزر نیم اور پاسورڈ درج کریں')),
      );
      return;
    }

    if (!_isCustomerLogin) {
      // ایڈمن لاگ ان چیک
      if (username == 'admin' && password == '1234') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ایڈمن لاگ ان کامیاب ہو گیا!')),
        );
        // کامیاب لاگ ان کے بعد ہوم پیج / ایڈمن پینل پر ری ڈائریکٹ کرنا
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('غلط ایڈمن یوزر نیم یا پاسورڈ')),
        );
      }
    } else {
      // کسٹمر لاگ ان چیک
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('کسٹمر ($username) کا لاگ ان ویریفائی ہو رہا ہے...')),
      );
    }
  }

  // فنگر پرنٹ لاگ ان کا فنکشن
  Future<void> _handleBiometricLogin() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isSupported = await auth.isDeviceSupported();

      if (canCheckBiometrics || isSupported) {
        bool didAuthenticate = await auth.authenticate(
          localizedReason: 'ڈیش بورڈ کھولنے کے لیے فنگر پرنٹ کی تصدیق کریں',
        );

        if (!mounted) return;

        if (didAuthenticate) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اس ڈیوائس میں فنگر پرنٹ سکیورٹی دستیاب نہیں ہے')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خرابی: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.red.shade200, width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red.shade100, width: 1),
                      ),
                      child: Icon(Icons.phone_android, size: 36, color: Colors.red[800]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'نایاب قسط پوائنٹ',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red[800]),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'آسان قسطوں پر موبائل اور الیکٹرانکس',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 25),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isCustomerLogin = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _isCustomerLogin ? Colors.red[800] : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'کسٹمر لاگ ان',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold, color: _isCustomerLogin ? Colors.white : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isCustomerLogin = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isCustomerLogin ? Colors.red[800] : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'ایڈمن لاگ ان',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold, color: !_isCustomerLogin ? Colors.white : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: _isCustomerLogin ? 'فون نمبر / شناختی کارڈ' : 'ایڈمن یوزر نیم',
                      prefixIcon: Icon(Icons.person, color: Colors.red[800]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'پاسورڈ / پن کوڈ',
                      prefixIcon: Icon(Icons.lock, color: Colors.red[800]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),

                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(_isCustomerLogin ? 'کسٹمر ڈیش بورڈ کھولیں' : 'ایڈمن پینل لاگ ان'),
                  ),
                  const SizedBox(height: 12),

                  // فنگر پرنٹ (Biometric) لاگ ان بٹن
                  OutlinedButton.icon(
                    onPressed: _handleBiometricLogin,
                    icon: Icon(Icons.fingerprint, color: Colors.red[800], size: 28),
                    label: const Text(
                      'فنگر پرنٹ سے لاگ ان کریں',
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.red.shade300, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // پاسورڈ بھول جانے کی صورت میں ایڈمن سے رابطہ کرنے کا سرخ پیغام
                  Center(
                    child: Text(
                      'پاسورڈ بھول جانے کی صورت میں ایڈمن سے رابطہ کریں',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('اکاؤنٹ نہیں بنا ہوا؟ ', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupPage()),
                          );
                        },
                        child: Text(
                          'نیا اکاؤنٹ بنائیں',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red[800], decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(thickness: 1, color: Colors.grey),
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InstallmentCalculaterPage()),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calculate, color: Colors.red[800], size: 28),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('آن لائن قسط کیلکولیٹر', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                SizedBox(height: 2),
                                Text('بغیر لاگ ان کیے اپنی ماہانہ قسط چیک کریں', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red[800]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}