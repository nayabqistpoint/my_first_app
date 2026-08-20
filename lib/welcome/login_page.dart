import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_first_app/welcome/signup_page.dart'; 
import 'package:my_first_app/installment_calculator_page.dart'; 
import 'package:my_first_app/home_page.dart'; 
import 'package:my_first_app/customer_ledger_page.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isCustomerLogin = true;
  bool _obscurePassword = true; 
  bool _rememberMe = false;    

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final LocalAuthentication auth = LocalAuthentication();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // محفوظ شدہ ڈیٹا لوڈ کرنے کا فنکشن
  Future<void> _loadSavedCredentials() async {
    try {
      var settingsBox = await Hive.openBox('settingsBox');
      bool savedRemember = settingsBox.get('rememberMe', defaultValue: false);
      if (savedRemember) {
        setState(() {
          _rememberMe = true;
          _usernameController.text = settingsBox.get('savedUsername', defaultValue: '');
          _passwordController.text = settingsBox.get('savedPassword', defaultValue: '');
        });
      }
    } catch (e) {
      // اگر باکس کھلنے میں کوئی مسئلہ ہو تو اگنور کریں
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
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

  Future<void> _openWhatsApp(String phoneNumber) async {
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
      // ریممبر می کا ڈیٹا ہائیو میں محفوظ یا ڈیلیٹ کرنا
      var settingsBox = await Hive.openBox('settingsBox');
      if (_rememberMe) {
        await settingsBox.put('rememberMe', true);
        await settingsBox.put('savedUsername', username);
        await settingsBox.put('savedPassword', password);
      } else {
        await settingsBox.put('rememberMe', false);
        await settingsBox.delete('savedUsername');
        await settingsBox.delete('savedPassword');
      }

      if (!_isCustomerLogin) {
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
        String cleanPhone = username.replaceAll(RegExp(r'[^0-9]'), '');
        
        if (cleanPhone.length < 10) {
          throw 'براہ کرم درست موبائل نمبر درج کریں';
        }

        var customerBox = Hive.box('customerBox');
        bool isCustomerFoundInHive = false;
        Map<String, dynamic> foundCustomerData = {};

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
                foundCustomerData = Map<String, dynamic>.from(customerData);
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
            // یہاں کسٹمر کا ڈیٹا اور isAdmin: false پاس کر دیا گیا ہے
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerLedgerPage(
                  customerData: foundCustomerData,
                  isAdmin: false, 
                ),
              ),
            );
          }
        } else {
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
              MaterialPageRoute(
                builder: (context) => CustomerLedgerPage(
                  customerData: {'name': username},
                  isAdmin: false,
                ),
              ),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.all(16.0), 
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.red.shade200, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red.shade100, width: 1),
                      ),
                      child: Icon(Icons.phone_android, size: 28, color: Colors.red[800]),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'نایاب قسط پوائنٹ',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[800]),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'آسان قسطوں پر موبائل اور الیکٹرانکس',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isCustomerLogin = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _isCustomerLogin ? Colors.red[800] : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'کسٹمر لاگ ان',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _isCustomerLogin ? Colors.white : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isCustomerLogin = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: !_isCustomerLogin ? Colors.red[800] : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'ایڈمن لاگ ان',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: !_isCustomerLogin ? Colors.white : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _usernameController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: _isCustomerLogin ? 'موبایل نمبر' : 'ایڈمن یوزر نیم',
                      labelStyle: const TextStyle(fontSize: 13),
                      prefixIcon: Icon(Icons.person, color: Colors.red[800], size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword, 
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: _isCustomerLogin ? 'پاسورڈ (PIN)' : 'ایڈمن پاسورڈ',
                      labelStyle: const TextStyle(fontSize: 13),
                      prefixIcon: Icon(Icons.lock, color: Colors.red[800], size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: Colors.red[800],
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('پاسورڈ یاد رکھیں', style: TextStyle(fontSize: 11, color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(_isCustomerLogin ? 'کسٹمر ڈیش بورڈ کھولیں' : 'ایڈمن پینل لاگ ان', style: const TextStyle(fontSize: 13)),
                  ),
                  const SizedBox(height: 8),

                  OutlinedButton.icon(
                    onPressed: _handleBiometricLogin,
                    icon: Icon(Icons.fingerprint, color: Colors.red[800], size: 22),
                    label: const Text(
                      'فنگر پرنٹ سے لاگ ان کریں',
                      style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(color: Colors.red.shade300, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ہیلپ سیکشن (بڑے اور کھلے ہوئے بٹن)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'معلومات یا پاسورڈ کے لیے رابطہ کریں:',
                          style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'حافظ محمد صابر - 03012700351',
                          style: TextStyle(fontSize: 11, color: Colors.red[800], fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _makePhoneCall('03012700351'),
                                icon: const Icon(Icons.call, size: 16),
                                label: const Text('کال کریں', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _openWhatsApp('03012700351'),
                                icon: const Icon(Icons.chat, size: 16),
                                label: const Text('واٹس ایپ', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('اکاؤنٹ نہیں بنا ہوا؟ ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupPage()),
                          );
                        },
                        child: Text(
                          'نیا اکاؤنٹ بنائیں',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red[800], decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InstallmentCalculaterPage()),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calculate, color: Colors.red[800], size: 22),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('آن لائن قسط کیلکولیٹر', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                Text('بغیر لاگ ان کیے ماہانہ قسط چیک کریں', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.red[800]),
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