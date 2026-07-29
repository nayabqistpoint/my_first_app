import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  bool _hasGuarantor = false;
  bool _hasSecurityCheck = false;
  
  bool _isCheckedTerms = false;
  bool _hasScrolledToBottom = false;
  final ScrollController _termsScrollController = ScrollController();

  String? _customerSelfiePath;

  String? _selectionMode; // 'stock' یا 'manual'
  String? _selectedStockItem;
  
  // یہاں ہم نے لسٹ کو کھولنے اور بند کرنے کا کنٹرولر رکھ لیا ہے
  bool _isPackageDropdownOpen = false;
  Map<String, dynamic>? _selectedCalculatorPackage;

  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _advanceAmountController = TextEditingController();
  final TextEditingController _itemModelController = TextEditingController();
  
  final TextEditingController _checkNumberController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _casteController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _guarantorNameController = TextEditingController();
  final TextEditingController _guarantorFatherNameController = TextEditingController();
  final TextEditingController _guarantorCasteController = TextEditingController();
  final TextEditingController _guarantorPhoneController = TextEditingController();
  final TextEditingController _guarantorCnicController = TextEditingController();
  final TextEditingController _guarantorAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _termsScrollController.addListener(() {
      if (_termsScrollController.position.pixels >=
          _termsScrollController.position.maxScrollExtent - 20) {
        if (!_hasScrolledToBottom) {
          setState(() {
            _hasScrolledToBottom = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _termsScrollController.dispose();
    _nameController.dispose();
    _fatherNameController.dispose();
    _casteController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _addressController.dispose();
    _itemModelController.dispose();
    _itemPriceController.dispose();
    _advanceAmountController.dispose();
    _checkNumberController.dispose();
    _bankNameController.dispose();
    _guarantorNameController.dispose();
    _guarantorFatherNameController.dispose();
    _guarantorCasteController.dispose();
    _guarantorPhoneController.dispose();
    _guarantorCnicController.dispose();
    _guarantorAddressController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _calculatePackages(double basePrice) {
    List<Map<String, dynamic>> packages = [];
    List<int> monthsList = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

    for (int months in monthsList) {
      double markup = basePrice * (0.03 * months); 
      double totalPrice = basePrice + markup;
      
      double advanceA = basePrice * 0.20;
      double remainingA = totalPrice - advanceA;
      double installmentA = remainingA / months;

      packages.add({
        'key': '${months}A',
        'title': 'پیکج ${months}A ($months ماہ - ایڈوانس کے ساتھ)',
        'months': months,
        'advance': advanceA.round(),
        'installment': installmentA.round(),
        'total': totalPrice.round(),
        'isAdvanceType': true,
      });

      if (months <= 6) {
        double installmentB = totalPrice / months;
        packages.add({
          'key': '${months}B',
          'title': 'پیکج ${months}B ($months ماہ - بغیر ایڈوانس)',
          'months': months,
          'advance': 0,
          'installment': installmentB.round(),
          'total': totalPrice.round(),
          'isAdvanceType': false,
        });
      }
    }
    return packages;
  }

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      var customerBox = Hive.box('customerBox');

      Map<String, dynamic> requestData = {
        'name': _nameController.text,
        'fatherName': _fatherNameController.text,
        'caste': _casteController.text,
        'phone': _phoneController.text,
        'cnic': _cnicController.text,
        'address': _addressController.text,
        'customerSelfie': _customerSelfiePath ?? '',
        'itemModel': _selectedStockItem ?? _itemModelController.text,
        'itemPrice': _itemPriceController.text,
        'packageKey': _selectedCalculatorPackage?['key'],
        'packageTitle': _selectedCalculatorPackage?['title'],
        'advanceAmount': _advanceAmountController.text,
        'monthlyInstallment': _selectedCalculatorPackage?['installment'].toString(),
        'totalPrice': _selectedCalculatorPackage?['total'].toString(),
        'hasStampPaper': true, 
        'hasCheck': _hasSecurityCheck,
        'bankName': _bankNameController.text,
        'checkNumber': _checkNumberController.text,
        'hasGuarantor': _hasGuarantor,
        'guarantorName': _guarantorNameController.text,
        'guarantorFatherName': _guarantorFatherNameController.text,
        'guarantorCaste': _guarantorCasteController.text,
        'guarantorPhone': _guarantorPhoneController.text,
        'guarantorCnic': _guarantorCnicController.text,
        'guarantorAddress': _guarantorAddressController.text,
        'status': 'Pending',
        'timestamp': DateTime.now().toString(),
      };

      await customerBox.add(requestData);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ڈیٹا محفوظ ہو گیا'),
          content: const Text('کسٹمر کی رجسٹریشن کامیابی سے محفوظ کر دی گئی ہے۔'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _formKey.currentState!.reset();
              },
              child: const Text('ٹھیک ہے'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, double> availableStockWithPrices = {
      'Vivo Y20 (دستیاب اسٹاک)': 32000,
      'Samsung Galaxy A12 (دستیاب اسٹاک)': 38000,
      'Oppo A54 (دستیاب اسٹاک)': 35000,
      'Xiaomi Redmi 9T (دستیاب اسٹاک)': 30000,
      'Infinix Hot 10 (دستیاب اسٹاک)': 27000,
    };

    double currentItemPrice = double.tryParse(_itemPriceController.text) ?? 0;
    List<Map<String, dynamic>> calculatedList = currentItemPrice > 0 ? _calculatePackages(currentItemPrice) : [];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        title: const Text('نیا کسٹمر رجسٹریشن (فائنل ورژن)', style: TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _submitData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text(
            'رجسٹریشن محفوظ کریں',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            
            // 1. کسٹمر کی ذاتی معلومات
            _buildSectionHeader('1. کسٹمر کی ذاتی معلومات', Icons.person),
            const SizedBox(height: 10),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTextField('کسٹمر کا پورا نام', Icons.badge, controller: _nameController),
                    const SizedBox(height: 12),
                    _buildTextField('والد / شوہر کا نام', Icons.person_outline, controller: _fatherNameController),
                    const SizedBox(height: 12),
                    _buildTextField('قوم (مثلاً: آرائیں، بلوچ، ملک)', Icons.group, controller: _casteController),
                    const SizedBox(height: 12),
                    _buildTextField('موبائل نمبر', Icons.phone, controller: _phoneController, keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    _buildTextField('شناختی کارڈ نمبر (CNIC)', Icons.credit_card, controller: _cnicController, keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    _buildTextField('مکمل گھر کا پتہ', Icons.home, controller: _addressController),
                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.camera_alt, color: Colors.red),
                              SizedBox(width: 8),
                              Text('کسٹمر کی لائیو سیلفی', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _customerSelfiePath = 'selfie_captured_dummy.jpg';
                              });
                            },
                            icon: const Icon(Icons.camera, size: 16),
                            label: Text(_customerSelfiePath == null ? 'تصویر لیں' : 'تصویر موجود ہے'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800], foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. سکیورٹی اور قانونی دستاویزات
            _buildSectionHeader('2. سکیورٹی اور قانونی دستاویزات', Icons.verified_user),
            const SizedBox(height: 10),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'نوٹ: اسٹامپ پیپر اور پرا نوٹ ہر ٹرانزیکشن کے لیے لازمی ہیں۔',
                        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('کیا کسٹمر نے ایڈوانس چیک دیا ہے؟', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      value: _hasSecurityCheck,
                      activeThumbColor: Colors.red[800],
                      onChanged: (bool value) {
                        setState(() {
                          _hasSecurityCheck = value;
                        });
                      },
                    ),

                    if (_hasSecurityCheck) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            _buildTextField('بینک کا نام', Icons.account_balance, controller: _bankNameController),
                            const SizedBox(height: 10),
                            _buildTextField('چیک نمبر', Icons.confirmation_number, controller: _checkNumberController, keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. آئٹم اور کیلکولیٹر لسٹ
            _buildSectionHeader('3. آئٹم اور کیلکولیٹر پیکجز لسٹ', Icons.shopping_bag),
            const SizedBox(height: 10),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('آئٹم درج کرنے کا طریقہ منتخب کریں:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    
                    RadioGroup<String>(
                      groupValue: _selectionMode,
                      onChanged: (val) {
                        setState(() {
                          _selectionMode = val;
                          _selectedStockItem = null;
                          _itemModelController.clear();
                          _itemPriceController.clear();
                          _selectedCalculatorPackage = null;
                          _isPackageDropdownOpen = false;
                          _advanceAmountController.clear();
                        });
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('دستیاب اسٹاک', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              value: 'stock',
                              activeColor: Colors.red[800],
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('مینوئل (اپنی مرضی)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              value: 'manual',
                              activeColor: Colors.red[800],
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_selectionMode == 'stock') ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedStockItem,
                        hint: const Text('اسٹاک سے موبائل منتخب کریں'),
                        decoration: InputDecoration(
                          labelText: 'دکان کا موجودہ اسٹاک',
                          prefixIcon: Icon(Icons.inventory_2, color: Colors.red[800]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: availableStockWithPrices.keys.map<DropdownMenuItem<String>>((String key) {
                          return DropdownMenuItem<String>(
                            value: key,
                            child: Text(key),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStockItem = newValue;
                            if (newValue != null) {
                              _itemModelController.text = newValue;
                              _itemPriceController.text = availableStockWithPrices[newValue].toString();
                              _selectedCalculatorPackage = null;
                              _isPackageDropdownOpen = false;
                            }
                          });
                        },
                      ),
                    ],

                    if (_selectionMode == 'manual') ...[
                      const SizedBox(height: 12),
                      _buildTextField('آئٹم / ماڈل کا نام لکھیں', Icons.phone_android, controller: _itemModelController, onChanged: (val) {
                        setState(() {});
                      }),
                      
                      if (_itemModelController.text.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildTextField('آئٹم کی اصل نقد قیمت درج کریں', Icons.money, controller: _itemPriceController, keyboardType: TextInputType.number, onChanged: (val) {
                          setState(() {
                            _selectedCalculatorPackage = null;
                            _isPackageDropdownOpen = false;
                          });
                        }),
                      ],
                    ],

                    // جب قیمت درج ہو جائے تو یہاں لسٹ کھلنے والا خوبصورت ڈراپ ڈاؤن باکس آئے گا
                    if (calculatedList.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'قسطوں کا پلان (پیکج منتخب کریں):',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(height: 8),

                      // سلیکٹڈ باکس جو ہمیشہ بند حالت میں یا منتخب پیکج دکھائے گا
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isPackageDropdownOpen = !_isPackageDropdownOpen;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade300, width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedCalculatorPackage != null 
                                      ? _selectedCalculatorPackage!['title'] 
                                      : 'مطلوبہ پیکج منتخب کرنے کے لیے یہاں دبائیں...',
                                  style: TextStyle(
                                    fontSize: 13, 
                                    fontWeight: FontWeight.bold,
                                    color: _selectedCalculatorPackage != null ? Colors.red[800] : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              Icon(
                                _isPackageDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                color: Colors.red[800],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // اگر یوزر نے کلک کیا ہو تو مکمل لسٹ نیچے کھلے گی، کلک کرتے ہی بند ہو جائے گی
                      if (_isPackageDropdownOpen) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.2),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: calculatedList.length,
                            itemBuilder: (context, index) {
                              var pkg = calculatedList[index];
                              bool isSelected = _selectedCalculatorPackage?['key'] == pkg['key'];

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCalculatorPackage = pkg;
                                    _advanceAmountController.text = pkg['advance'].toString();
                                    _isPackageDropdownOpen = false; // پیکج سلیکٹ ہوتے ہی لسٹ بند ہو جائے گی
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.red.shade50 : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? Colors.red.shade700 : Colors.grey.shade200,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          pkg['title'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.red[800] : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'ایڈوانس: ${pkg['advance']}',
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'قسط: ${pkg['installment']}',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'کل: ${pkg['total']}',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],

                    // جب پیکج منتخب ہو جائے تو نیچے الگ الگ تینوں خانے (باکسز) نظر آئیں گے تاکہ پی ڈی ایف اور ریکارڈ بہترین طریقے سے بنے
                    if (_selectedCalculatorPackage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'منتخب کردہ پیکج کی تفصیلات (پی ڈی ایف پرنٹ کے لیے تیار):',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
                            ),
                            const SizedBox(height: 10),
                            
                            // باکس 1: ایڈوانس رقم
                            TextFormField(
                              controller: _advanceAmountController,
                              keyboardType: TextInputType.number,
                              readOnly: !_selectedCalculatorPackage!['isAdvanceType'],
                              decoration: InputDecoration(
                                labelText: _selectedCalculatorPackage!['isAdvanceType'] ? 'ایڈوانس رقم (ترمیم کر سکتے ہیں)' : 'بغیر ایڈوانس پیکج (صفر)',
                                prefixIcon: Icon(Icons.payment, color: Colors.red[800], size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                filled: true,
                                fillColor: !_selectedCalculatorPackage!['isAdvanceType'] ? Colors.grey.shade200 : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            // باکس 2 اور 3: ماہانہ قسط اور کل رقم کا ڈسپلے
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                                  child: Text('ماہانہ قسط: ${_selectedCalculatorPackage!['installment']} روپے', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                                  child: Text('کل رقم: ${_selectedCalculatorPackage!['total']} روپے', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 4. ضامن کی معلومات
            _buildSectionHeader('4. ضامن کی معلومات', Icons.people),
            const SizedBox(height: 10),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('کیا اس کیس میں ضامن شامل ہے؟', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      value: _hasGuarantor,
                      activeThumbColor: Colors.red[800],
                      onChanged: (bool value) {
                        setState(() {
                          _hasGuarantor = value;
                        });
                      },
                    ),

                    if (_hasGuarantor) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            _buildTextField('ضامن کا نام', Icons.person_outline, controller: _guarantorNameController),
                            const SizedBox(height: 10),
                            _buildTextField('ضامن کے والد / شوہر کا نام', Icons.person, controller: _guarantorFatherNameController),
                            const SizedBox(height: 10),
                            _buildTextField('ضامن کی قوم', Icons.group, controller: _guarantorCasteController),
                            const SizedBox(height: 10),
                            _buildTextField('ضامن کا فون نمبر', Icons.phone, controller: _guarantorPhoneController, keyboardType: TextInputType.phone),
                            const SizedBox(height: 10),
                            _buildTextField('ضامن کا شناختی کارڈ (CNIC)', Icons.credit_card, controller: _guarantorCnicController, keyboardType: TextInputType.number),
                            const SizedBox(height: 10),
                            _buildTextField('ضامن کا پتہ اور رشتہ', Icons.location_on, controller: _guarantorAddressController),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 5. اسکرولیبل اقرار نامہ
            _buildSectionHeader('5. اقرار نامہ اور ضابطہ اخلاق', Icons.gavel),
            const SizedBox(height: 10),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'براہ کرم درج ذیل بیان حلفی اور شرائط کو آخر تک پڑھیں:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 140,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Scrollbar(
                        controller: _termsScrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _termsScrollController,
                          child: const Text(
                            'میں ہوش و حواس میں اقرار کرتا/کرتی ہوں کہ میں یہ موبائل قسطوں پر لے رہا/رہی ہوں۔ تمام درج کردہ کوائف بشمول نام، ولدیت اور قوم سو فیصد درست ہیں۔ میں بروقت ماہانہ قسط ادا کرنے کا مکمل پابند ہوں۔ کسی بھی تنازع یا خلاف ورزی کی صورت میں معاملہ عدالت جانے کے بجائے ہمارے پہلے سے طے شدہ ثالثوں کے بورڈ کے سامنے پیش کیا جائے گا، اور ثالثی ایکٹ کے تحت فیصلہ صادر ہوگا۔ تمام شرائط و ضوابط مجھ پر لازم ہوں گے۔ (براہ کرم اس عبارت کو آخر تک اسکرول کریں)',
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      title: const Text('میں نے شرائط پڑھ لی ہیں اور ان سے متفق ہوں', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      value: _isCheckedTerms,
                      activeColor: Colors.red[800],
                      onChanged: _hasScrolledToBottom
                          ? (bool? value) {
                              setState(() {
                                _isCheckedTerms = value ?? false;
                              });
                            }
                          : null,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    if (!_hasScrolledToBottom)
                      const Padding(
                        padding: EdgeInsets.only(left: 12.0),
                        child: Text(
                          'چیک باکس کو فعال کرنے کے لیے اوپر دیے گئے اقرار نامے کو آخر تک اسکرول کریں',
                          style: TextStyle(color: Colors.red, fontSize: 11),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.red[800], size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red[800],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, {TextEditingController? controller, TextInputType keyboardType = TextInputType.text, void Function(String)? onChanged}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.red[800], size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}