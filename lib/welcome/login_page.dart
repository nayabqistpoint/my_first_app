import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'signup_page.dart'; 
import '../installment_calculater_page.dart'; 
import '../home_page.dart'; 
import '../customer_ledger_page.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isCustomerLogin = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final LocalAuthentication auth = LocalAuthentication();
  bool _isLoading = false;

  // ڈائریکٹ کال کرنے کا فنکشن
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('کال کرنے میں مسئلہ پیش آیا')),
        );
      }
    }
  }

  // نمبر سیو کیے بغیر ڈائریکٹ واٹس ایپ چیٹ کھولنے کا فنکشن
  Future<void> _openWhatsApp(String phoneNumber) async {
    // پاکستانی نمبر کے لیے 92 کا اضافہ اور پلس یا صفر کی صفائی
    String formattedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '92${formattedPhone.substring(1)}';
    }

    final Uri whatsappUri = Uri.parse('https://wa.me/$formattedPhone?text=السلام علیکم حافظ صابر صاحب، مجھے لاگ ان یا پاسورڈ کے معاملے میں مدد درکار ہے۔');
    
    try {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('واٹس ایپ کھولنے میں مسئلہ پیش آیا')),
        );
      }
    }
  }

  Future<void> _handleLogin() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('براہ کرم موبائل نمبر اور پاسورڈ درج کریں')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (!_isCustomerLogin) {
        // ایڈمن لاگ ان چیک
        if (username == 'admin' && password == '1234') {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('غلط ایڈمن یوزر نیم یا پاسورڈ')),
            );
          }
        }
      } else {
        // کسٹمر لاگ ان: ہائیو (Hive) میں چیک کریں
        String cleanPhone = username.replaceAll(RegExp(r'[^0-9]'), '');
        
        if (cleanPhone.length < 10) {
          throw 'براہ کرم درست موبائل نمبر درج کریں';
        }

        var customerBox = Hive.box('customerBox');
        bool isCustomerFoundInHive = false;

        for (var key in customerBox.keys) {
          var customerData = customerBox.get(key);
          if (customerData != null && customerData is Map) {
            String savedPhone = customerData['customerPhone'] ?? 
                                 customerData['phone'] ?? 
                                 customerData['mobile'] ?? '';
            
            String cleanSavedPhone = savedPhone.replaceAll(RegExp(r'[^0-9]'), '');

            if (cleanSavedPhone == cleanPhone) {
              String expectedPin = cleanSavedPhone.length >= 4 
                  ? cleanSavedPhone.substring(cleanSavedPhone.length - 4) 
                  : cleanSavedPhone;

              if (password == expectedPin) {
                isCustomerFoundInHive = true;
                break;
              }
            }
          }
        }

        if (isCustomerFoundInHive) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لاگ ان کامیاب ہو گیا!')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CustomerLedgerPage()),
            );
          }
        } else {
          // اگر ہائیو میں نہ ملے تو فائر بیس سے کوشش کریں
          String fakeEmail = '$cleanPhone@nayabqist.com';
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: fakeEmail,
            password: password,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لاگ ان کامیاب ہو گیا!')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CustomerLedgerPage()),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لاگ ان ناکام: درج کردہ موبائل نمبر یا پاسورڈ درست نہیں ہے'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: _isCustomerLogin ? 'موبائل نمبر' : 'ایڈمن یوزر نیم',
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
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: _isCustomerLogin ? 'پاسورڈ (PIN)' : 'ایڈمن پاسورڈ',
                      prefixIcon: Icon(Icons.lock, color: Colors.red[800]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(_isCustomerLogin ? 'کسٹمر ڈیش بورڈ کھولیں' : 'ایڈمن پینل لاگ ان'),
                  ),
                  const SizedBox(height: 12),

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
                  const SizedBox(height: 15),

                  // حافظ محمد صابر صاحب کا نام، کال اور واٹس ایپ کے ڈائریکٹ لنکس
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'کسی بھی معلومات، مدد یا پاسورڈ کے لیے رابطہ کریں:',
                          style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'حافظ محمد صابر\n03012700351',
                          style: TextStyle(fontSize: 13, color: Colors.red[800], fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _makePhoneCall('03012700351'),
                              icon: const Icon(Icons.call, size: 16),
                              label: const Text('ڈائریکٹ کال'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () => _openWhatsApp('03012700351'),
                              icon: const Icon(Icons.chat, size: 16),
                              label: const Text('واٹس ایپ چیٹ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                    padding: EdgeInsets.symmetric(vertical: 15),
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