import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentInDialog extends StatefulWidget {
  const PaymentInDialog({super.key});

  @override
  State<PaymentInDialog> createState() => _PaymentInDialogState();
}

class _PaymentInDialogState extends State<PaymentInDialog> {
  final TextEditingController _customerNameController = TextEditingController(); 
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  double _liveTotal = 0.0;

  String _selectedBank = 'لاکر (Locker)';
  final List<String> _bankList = [
    'لاکر (Locker)',
    'احمد (دستی لین دین)',
    'میزان بینک',
    'ایزی پیسہ',
    'جائز کیش',
    'الائیڈ بینک'
  ];

  bool _hasImage = false;
  bool _hasPdf = false;
  bool _hasAudio = false;
  bool _hasVideo = false;

  @override
  void initState() {
    super.initState();
    _cashController.addListener(_calculateTotal);
    _bankController.addListener(_calculateTotal);
    _discountController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _cashController.dispose();
    _bankController.dispose();
    _discountController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final double cash = double.tryParse(_cashController.text.trim()) ?? 0.0;
    final double bank = double.tryParse(_bankController.text.trim()) ?? 0.0;
    final double discount = double.tryParse(_discountController.text.trim()) ?? 0.0;

    setState(() {
      _liveTotal = cash + bank + discount;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
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

  Future<void> _shareOnWhatsApp() async {
    String message = "🧾 *رسید - ادائیگی وصولی (Payment In)*\n"
        "کسٹمر کا نام: ${_customerNameController.text.isEmpty ? 'معزز کسٹمر' : _customerNameController.text}\n"
        "تاریخ: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}\n"
        "-------------------\n"
        "کیش رقم: ${_cashController.text.isEmpty ? '0' : _cashController.text} روپے\n"
        "بینک رقم: ${_bankController.text.isEmpty ? '0' : _bankController.text} روپے ($_selectedBank)\n"
        "رعایت / ڈسکاؤنٹ: ${_discountController.text.isEmpty ? '0' : _discountController.text} روپے\n"
        "-------------------\n"
        "کل موصولہ رقم: *$_liveTotal روپے*\n"
        "تفصیل: ${_detailsController.text.isEmpty ? 'پیمنٹ وصولی' : _detailsController.text}\n"
        "شکریہ!";
    
    final Uri whatsappUrl = Uri.parse("whatsapp://send?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
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
                    'پیمنٹ وصولی رسید (Payment In)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  IconButton(
                    icon: const Icon(Icons.reply, size: 30, color: Colors.blue),
                    tooltip: 'واٹس ایپ پر شیئر کریں',
                    onPressed: _shareOnWhatsApp,
                  ),
                ],
              ),
              const Divider(),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'کسٹمر کا نام (ضروری)',
                        border: UnderlineInputBorder(),
                        prefixIcon: Icon(Icons.person, color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'تاریخ: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: const Text('تبدیل کریں', style: TextStyle(fontSize: 12, color: Color(0xFF0D47A1))),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),

              const Text('وصولی کی تفصیل درج کریں:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),

              TextField(
                controller: _cashController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'کیش رقم (Cash)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wallet, color: Colors.green),
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
                        labelText: 'بینک رقم (Bank)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_balance, color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      // یہاں value کو اب initialValue سے تبدیل کر دیا گیا ہے
                      initialValue: _selectedBank,
                      decoration: const InputDecoration(
                        labelText: 'بینک / بندہ',
                        border: OutlineInputBorder(),
                      ),
                      items: _bankList.map((bank) {
                        return DropdownMenuItem(value: bank, child: Text(bank, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedBank = val!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'رعایت / ڈسکاؤنٹ (Discount)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.percent, color: Colors.orange),
                ),
              ),
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
                    icon: Icon(Icons.image, color: _hasImage ? Colors.green : Colors.grey, size: 30),
                    onPressed: () => setState(() => _hasImage = !_hasImage),
                  ),
                  IconButton(
                    icon: Icon(Icons.picture_as_pdf, color: _hasPdf ? Colors.red : Colors.grey, size: 30),
                    onPressed: () => setState(() => _hasPdf = !_hasPdf),
                  ),
                  IconButton(
                    icon: Icon(Icons.mic, color: _hasAudio ? Colors.blue : Colors.grey, size: 30),
                    onPressed: () => setState(() => _hasAudio = !_hasAudio),
                  ),
                  IconButton(
                    icon: Icon(Icons.videocam, color: _hasVideo ? Colors.purple : Colors.grey, size: 30),
                    onPressed: () => setState(() => _hasVideo = !_hasVideo),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('کل موصولہ رقم:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
                    Text('Rs. ${_liveTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_customerNameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('برائے مہربانی کسٹمر کا نام درج کریں!')),
                      );
                      return;
                    }
                    if (_liveTotal == 0.0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('برائے مہربانی کوئی رقم درج کریں!')),
                      );
                      return;
                    }

                    Navigator.pop(context, {
                      'customer_name': _customerNameController.text.trim(),
                      'cash_amount': double.tryParse(_cashController.text.trim()) ?? 0.0,
                      'bank_amount': double.tryParse(_bankController.text.trim()) ?? 0.0,
                      'bank_name': _selectedBank,
                      'discount': double.tryParse(_discountController.text.trim()) ?? 0.0,
                      'amount': _liveTotal,
                      'date': '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      'details': _detailsController.text.trim().isEmpty 
                          ? 'پیمنٹ وصولی' 
                          : _detailsController.text.trim(),
                      'attachments': {
                        'image': _hasImage,
                        'pdf': _hasPdf,
                        'audio': _hasAudio,
                        'video': _hasVideo,
                      }
                    });
                  },
                  child: const Text(
                    'وصولی محفوظ کریں (Save In)',
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