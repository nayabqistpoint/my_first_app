import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentOutDialog extends StatefulWidget {
  const PaymentOutDialog({super.key});

  @override
  State<PaymentOutDialog> createState() => _PaymentOutDialogState();
}

class _PaymentOutDialogState extends State<PaymentOutDialog> {
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController(); 
  final TextEditingController _penaltyController = TextEditingController(); 

  final TextEditingController _totalPriceController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  final TextEditingController _installmentController = TextEditingController();
  final TextEditingController _imeiController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  String _transactionType = 'نقد'; 
  String _selectedItem = 'Vivo Y17s'; 
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30)); 
  DateTime _selectedDate = DateTime.now(); 
  double _liveTotal = 0.0;

  bool _hasImage = false;
  bool _hasPdf = false;
  bool _hasAudio = false;
  bool _hasVideo = false;

  final List<String> _stockItems = [
    'Vivo Y17s',
    'Samsung A15',
    'Infinix Hot 40',
    'Tecno Spark 20',
    'Realme C67',
    'Redmi 13C',
    'چارجر / ہینڈز فری پیکٹ'
  ];

  @override
  void initState() {
    super.initState();
    _cashController.addListener(_calculateTotal);
    _bankController.addListener(_calculateTotal);
    _penaltyController.addListener(_calculateTotal);

    _totalPriceController.addListener(_calculateSaleTotal);
    _advanceController.addListener(_calculateSaleTotal);
  }

  @override
  void dispose() {
    _cashController.dispose();
    _bankController.dispose();
    _bankNameController.dispose();
    _penaltyController.dispose();
    _totalPriceController.dispose();
    _advanceController.dispose();
    _installmentController.dispose();
    _imeiController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    if (_transactionType == 'نقد') {
      final double cash = double.tryParse(_cashController.text.trim()) ?? 0.0;
      final double bank = double.tryParse(_bankController.text.trim()) ?? 0.0;
      final double penalty = double.tryParse(_penaltyController.text.trim()) ?? 0.0;

      setState(() {
        _liveTotal = cash + bank + penalty;
      });
    }
  }

  void _calculateSaleTotal() {
    if (_transactionType == 'سیل') {
      final double total = double.tryParse(_totalPriceController.text.trim()) ?? 0.0;
      final double advance = double.tryParse(_advanceController.text.trim()) ?? 0.0;

      setState(() {
        _liveTotal = total - advance;
      });
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectTxDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _shareOutOnWhatsApp() async {
    String message = "";
    if (_transactionType == 'نقد') {
      message = "🧾 *رسید - ادائیگی (Payment Out)*\n"
          "تاریخ: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}\n"
          "-------------------\n"
          "کیش ادا کی: ${_cashController.text.isEmpty ? '0' : _cashController.text} روپے\n"
          "بینک بھیجی: ${_bankController.text.isEmpty ? '0' : _bankController.text} روپے (${_bankNameController.text.isEmpty ? 'کیش/بینک' : _bankNameController.text})\n"
          "جرمانہ / نقصان: ${_penaltyController.text.isEmpty ? '0' : _penaltyController.text} روپے\n"
          "-------------------\n"
          "کل ادا کردہ رقم: *$_liveTotal روپے*\n"
          "تفصیل: ${_detailsController.text.isEmpty ? 'پیمنٹ ادائیگی' : _detailsController.text}\n"
          "شکریہ!";
    } else {
      message = "🧾 *رسید - سیل / آئٹم بیچی (Item Sold)*\n"
          "تاریخ: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}\n"
          "آئٹم کا نام: $_selectedItem\n"
          "IMEI نمبر: ${_imeiController.text}\n"
          "-------------------\n"
          "کل قیمت: ${_totalPriceController.text} روپے\n"
          "ایڈوانس وصولی: ${_advanceController.text.isEmpty ? '0' : _advanceController.text} روپے\n"
          "قسط کی رقم: ${_installmentController.text} روپے\n"
          "وعدہ تاریخ اگلی قسط: ${_dueDate.day}/${_dueDate.month}/${_dueDate.year}\n"
          "-------------------\n"
          "باقی رقم (کھاتہ): *$_liveTotal روپے*\n"
          "تفصیل: ${_detailsController.text.isEmpty ? 'نیا اسمارٹ فون فروخت کیا' : _detailsController.text}\n"
          "شکریہ!";
    }
    
    final Uri whatsappUrl = Uri.parse("whatsapp://send?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      // یہاں ہم نے mounted چیک شامل کیا ہے تاکہ linter کا مسئلہ نہ آئے
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('واٹس ایپ اوپن کرنے میں مسئلہ آیا یا انسٹال نہیں ہے!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'پیمنٹ ادائیگی / سیل رسید',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  IconButton(
                    icon: const Icon(Icons.reply, size: 30, color: Colors.blue),
                    tooltip: 'واٹس ایپ پر شیئر کریں',
                    onPressed: _shareOutOnWhatsApp,
                  ),
                ],
              ),
              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تاریخ: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => _selectTxDate(context),
                    icon: const Icon(Icons.calendar_month, color: Color(0xFF0D47A1)),
                    label: const Text('تاریخ تبدیل کریں', style: TextStyle(color: Color(0xFF0D47A1))),
                  ),
                ],
              ),
              const Divider(),

              const Text('ادائیگی کی نوعیت منتخب کریں:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _transactionType = 'نقد';
                          _calculateTotal();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _transactionType == 'نقد' ? Colors.red.shade50 : Colors.grey.shade100,
                          border: Border.all(
                            color: _transactionType == 'نقد' ? Colors.red : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(child: Text('صرف پیسے دیئے (Cash Out)', style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _transactionType = 'سیل';
                          _calculateSaleTotal();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _transactionType == 'سیل' ? Colors.red.shade50 : Colors.grey.shade100,
                          border: Border.all(
                            color: _transactionType == 'سیل' ? Colors.red : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(child: Text('سیل / آئٹم بیچی (Item Sold)', style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_transactionType == 'نقد') ...[
                TextField(
                  controller: _cashController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'کیش رقم ادا کی (Cash Paid)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.wallet, color: Colors.red),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _bankController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'بینک رقم بھیجی (Bank Sent)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance, color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _bankNameController,
                        decoration: const InputDecoration(
                          labelText: 'نام بینک / کسٹمر',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _penaltyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'جرمانہ / فالتو نقصان (Penalty/Loss)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.gavel, color: Colors.orange),
                  ),
                ),
              ] else ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedItem,
                  decoration: const InputDecoration(
                    labelText: 'سٹاک آئٹم کا انتخاب کریں',
                    border: OutlineInputBorder(),
                  ),
                  items: _stockItems.map((item) {
                    return DropdownMenuItem(value: item, child: Text(item));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedItem = val!;
                    });
                  },
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _imeiController,
                  decoration: const InputDecoration(
                    labelText: 'IMEI / سیریل نمبر لکھیں',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phonelink_setup, color: Colors.blueGrey),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _totalPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'کل قیمتِ فروخت',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _advanceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'ایڈوانس وصولی',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _installmentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'قسط کی رقم',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_clock),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'وعدہ تاریخ (Due Date): ${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () => _selectDueDate(context),
                      icon: const Icon(Icons.edit_calendar, color: Colors.red),
                      label: const Text('تبدیل کریں'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),

              TextField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  labelText: 'تفصیل (Details)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 15),

              const Text('فائل اور ریکارڈنگ اٹیچمنٹس:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.image, color: _hasImage ? Colors.red : Colors.grey, size: 30),
                    onPressed: () => setState(() => _hasImage = !_hasImage),
                    tooltip: 'تصویر لگائیں',
                  ),
                  IconButton(
                    icon: Icon(Icons.picture_as_pdf, color: _hasPdf ? Colors.red : Colors.grey, size: 30),
                    onPressed: () => setState(() => _hasPdf = !_hasPdf),
                    tooltip: 'پی ڈی ایف جوڑیں',
                  ),
                  IconButton(
                    icon: Icon(Icons.mic, color: _hasAudio ? Colors.blue : Colors.grey, size: 30),
                    onPressed: () => setState(() => _hasAudio = !_hasAudio),
                    tooltip: 'آڈیو ریکارڈنگ',
                  ),
                  IconButton(
                    icon: Icon(Icons.videocam, color: _hasVideo ? Colors.purple : Colors.grey, size: 30),
                    onPressed: () => setState(() => _hasVideo = !_hasVideo),
                    tooltip: 'ویڈیو ریکارڈنگ',
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _transactionType == 'نقد' 
                          ? 'کل ادا کردہ رقم (ٹوٹل ادائیگی):' 
                          : 'باقی رقم (جو کھاتے میں چڑھے گی):',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red),
                    ),
                    Text('Rs. ${_liveTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_liveTotal == 0.0 && _transactionType == 'نقد') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('برائے مہربانی کوئی رقم درج کریں!')),
                      );
                      return;
                    }

                    String details = _detailsController.text.trim();
                    if (_transactionType == 'سیل') {
                      final double total = double.tryParse(_totalPriceController.text.trim()) ?? 0.0;
                      if (total == 0.0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('برائے مہربانی سیل کی کل قیمت درج کریں!')),
                        );
                        return;
                      }
                      if (details.isEmpty) {
                        details = 'فروخت کردہ: $_selectedItem (IMEI: ${_imeiController.text})';
                      }
                    } else {
                      if (details.isEmpty) details = 'پیمنٹ ادائیگی';
                    }

                    Navigator.pop(context, {
                      'amount': _liveTotal, 
                      'cash_amount': double.tryParse(_cashController.text.trim()) ?? 0.0,
                      'bank_amount': double.tryParse(_bankController.text.trim()) ?? 0.0,
                      'bank_name': _bankNameController.text.trim(),
                      'penalty': double.tryParse(_penaltyController.text.trim()) ?? 0.0,
                      'type': 'gave',
                      'date': '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      'details': details,
                      'sale_details': _transactionType == 'سیل' ? {
                        'item_name': _selectedItem,
                        'imei': _imeiController.text.trim(),
                        'total_price': double.tryParse(_totalPriceController.text.trim()) ?? 0.0,
                        'advance': double.tryParse(_advanceController.text.trim()) ?? 0.0,
                        'installment': double.tryParse(_installmentController.text.trim()) ?? 0.0,
                        'due_date': '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                      } : null,
                      'attachments': {
                        'image': _hasImage,
                        'pdf': _hasPdf,
                        'audio': _hasAudio,
                        'video': _hasVideo,
                      }
                    });
                  },
                  child: const Text(
                    'ادائیگی محفوظ کریں (Save Out)',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}