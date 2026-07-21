import 'package:flutter/material.dart';
import '../../dashboard/controller.dart';
import '../../dashboard/widgets/source_selecter.dart';

class SalePurchaseForm extends StatefulWidget {
  const SalePurchaseForm({super.key});

  @override
  State<SalePurchaseForm> createState() => _SalePurchaseFormState();
}

class _SalePurchaseFormState extends State<SalePurchaseForm> {
  // 0 = صرف پرچیز، 1 = صرف سیل، 2 = پرچیز اینڈ سیل
  int _selectedMode = 0;
  
  // اسپلٹ پیمنٹ کے ویری ایبلز
  double _cashAmount = 0;
  String? _selectedBank;
  double _bankAmount = 0;

  void _saveTransactionData() {
    if (_cashAmount > 0) {
      // کیش ہینڈلنگ لاجک
    }
    if (_bankAmount > 0 && _selectedBank != null) {
      // بینک ہینڈلنگ لاجک
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: dashboardController,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. ٹاپ ہیڈر اور موڈ سلیکٹر ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'خرید و فروخت (انواٹس بل)',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // جدید SegmentedButton (ریڈیو وارننگ کا مستقل خاتمہ)
              Center(
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(
                      value: 0,
                      label: Text('صرف پرچیز', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    ButtonSegment<int>(
                      value: 1,
                      label: Text('صرف سیل', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    ButtonSegment<int>(
                      value: 2,
                      label: Text('پرچیز اینڈ سیل', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  selected: {_selectedMode},
                  onSelectionChanged: (Set<int> newSelection) {
                    setState(() {
                      _selectedMode = newSelection.first;
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 1.5),
              const SizedBox(height: 10),

              // --- 2. تاریخ، واٹس ایپ اور پارٹی کا نام ---
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'تاریخ',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.calendar_today, size: 18, color: Color(0xFFE53935)),
                      ),
                      readOnly: true,
                      controller: TextEditingController(text: '21-7-2026'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'واٹس ایپ نمبر *',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'پارٹی کا نام *',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.person, color: Color(0xFFE53935)),
                ),
              ),
              const SizedBox(height: 16),

              // --- 3. آئٹمز کی تفصیلات ---
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '#1 آئٹم کی تفصیل',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              decoration: InputDecoration(labelText: 'موبائل ماڈل *', border: OutlineInputBorder(), isDense: true),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              decoration: InputDecoration(labelText: 'IMEI نمبر *', border: OutlineInputBorder(), isDense: true),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              decoration: InputDecoration(labelText: 'کلر', border: OutlineInputBorder(), isDense: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(labelText: 'تعداد', border: OutlineInputBorder(), isDense: true),
                              keyboardType: TextInputType.number,
                              controller: TextEditingController(text: '1'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(labelText: 'خرید قیمت', border: OutlineInputBorder(), isDense: true),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(labelText: 'فروخت قیمت', border: OutlineInputBorder(), isDense: true),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Color(0xFFE53935)),
                label: const Text('مزید آئٹم شامل کریں', style: TextStyle(color: Color(0xFFE53935))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE53935)),
                ),
              ),
              const SizedBox(height: 16),

              // --- 4. بل کی تفصیلات ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('گرانڈ ٹوٹل (خرید):', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('Rs 0', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Expanded(flex: 2, child: Text('رعایت (دکاندار کی طرف سے):', style: TextStyle(fontSize: 13))),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, prefixText: 'Rs '),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('فائنل ادائیگی کل رقم:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Text('Rs 0', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- 5. سورس سلیکٹر ---
              SourceSelecter(
                onSplitPaymentChanged: (bankSource, cashAmount, bankAmount) {
                  setState(() {
                    _selectedBank = bankSource;
                    _cashAmount = cashAmount;
                    _bankAmount = bankAmount;
                  });
                },
              ),
              const SizedBox(height: 20),

              // --- 6. محفوظ کرنے کے بٹنز ---
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _saveTransactionData();
                        },
                        icon: const Icon(Icons.share, color: Colors.white, size: 18),
                        label: const Text('محفوظ اور شیئر', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _saveTransactionData();
                        },
                        icon: const Icon(Icons.save, color: Colors.white, size: 18),
                        label: const Text('محفوظ کریں', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}