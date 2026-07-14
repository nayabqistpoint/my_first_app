import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // کنٹرولرز
  final TextEditingController _cashPriceController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();

  // بیک اینڈ ایڈمن ریٹس (ڈیفالٹ ویلیوز)
  double _noChequeBaseRate = 35.0; // بغیر چیک کے 6 ماہ کا ریٹ (%)
  double _withChequeBaseRate = 25.0; // چیک کے ساتھ 6 ماہ کا ریٹ (%)
  final double _monthlyIncrementRate = 5.0; // ہر اضافی ماہ کا ریٹ (%)

  // سٹیٹ ویری ایبلز
  bool _hasCheque = false;
  bool _isAdminMode = false;

  @override
  void dispose() {
    _cashPriceController.dispose();
    _advanceController.dispose();
    super.dispose();
  }

  // پرافٹ ریٹ کیلکولیٹ کرنے کا فارمولا
  double _getProfitRate(int months) {
    double baseRate = _hasCheque ? _withChequeBaseRate : _noChequeBaseRate;
    int extraMonths = months - 6;
    return baseRate + (extraMonths * _monthlyIncrementRate);
  }

  @override
  Widget build(BuildContext context) {
    final double rawCashPrice = double.tryParse(_cashPriceController.text) ?? 0;
    final double rawAdvance = double.tryParse(_advanceController.text) ?? 0;

    // موبائل قیمت کی حد 50,000 روپے
    final bool isPriceOverLimit = rawCashPrice > 50000;
    final bool hasValidPrice = rawCashPrice > 0 && !isPriceOverLimit;

    // 6 ماہ کے پیکج کے مطابق کم از کم ایڈوانس (6 ماہ کی بغیر ایڈوانس قسط کا 80%)
    double minAdvanceLimit = 0;
    if (hasValidPrice) {
      double rate6Months = _getProfitRate(6);
      double total6Months = rawCashPrice + (rawCashPrice * (rate6Months / 100));
      double installment6Months = total6Months / 6;
      minAdvanceLimit = installment6Months * 0.8;
    }

    final bool isAdvanceUnderLimit = hasValidPrice && rawAdvance > 0 && rawAdvance < minAdvanceLimit;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('قسط کیلکولیٹر', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF0D47A1),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(_isAdminMode ? Icons.lock_open : Icons.settings, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isAdminMode = !_isAdminMode;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isAdminMode ? 'ایڈمن کنٹرول موڈ فعال ہے!' : 'ایڈمن موڈ بند کر دیا گیا ہے'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ۱. خفیہ ایڈمن پینل (جب سیٹنگز آئیکن پر کلک ہو)
              if (_isAdminMode) _buildAdminPanel(),

              // ۲. کسٹمر ان پٹ سیکشن
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _cashPriceController,
                        keyboardType: TextInputType.number,
                        onChanged: (val) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'موبائل کی نقد قیمت (Cash Price)',
                          prefixText: 'Rs. ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _advanceController,
                        keyboardType: TextInputType.number,
                        onChanged: (val) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'ایڈوانس رقم (Advance Amount) - اختیاری',
                          prefixText: 'Rs. ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // چیک باکس کسٹمر کے لیے رعایتی ترغیب کے ساتھ
                      CheckboxListTile(
                        title: const Text(
                          'چیک (Cheque) فراہم کیا ہے؟',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        subtitle: const Text('چیک فراہم کرنے پر خصوصی 10% رعایت کے اہل بنیں'),
                        value: _hasCheque,
                        activeColor: const Color(0xFF0D47A1),
                        onChanged: (bool? value) {
                          setState(() {
                            _hasCheque = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ۳. الرٹس اور حدیں (Warnings & Limits)
              if (isPriceOverLimit)
                _buildWarningBanner(
                  '50,000 سے اوپر کی خریداری کے لیے ہمارے نمائندے سے براہِ راست رابطہ فرمائیں۔',
                  Colors.orange.shade800,
                )
              else if (isAdvanceUnderLimit)
                _buildWarningBanner(
                  'اس نقد رقم کے لیے کم از کم ایڈوانس Rs. ${minAdvanceLimit.toStringAsFixed(0)} ہونا لازمی ہے۔',
                  Colors.red.shade800,
                ),

              // ۴. پیکجز کی فہرست (ایک ساتھ تمام آپشنز)
              if (hasValidPrice) ...[
                const Text(
                  'دستیاب اقساط کے پیکجز:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 7, // 6 سے 12 مہینے (کل 7 پیکجز)
                  itemBuilder: (context, index) {
                    int months = index + 6;
                    double rate = _getProfitRate(months);
                    double totalPrice = rawCashPrice + (rawCashPrice * (rate / 100));

                    // ایڈوانس کے بغیر قسط
                    double installmentNoAdvance = totalPrice / months;

                    // ایڈوانس کے ساتھ قسط (ایڈوانس دینے پر باقی مہینوں پر تقسیم)
                    double installmentWithAdvance = 0;
                    if (rawAdvance >= minAdvanceLimit) {
                      double remainingPrice = totalPrice - rawAdvance;
                      installmentWithAdvance = remainingPrice / (months - 1);
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.blue.shade100, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '📦 $months ماہ کا پیکج',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                                ),
                                Text(
                                  'کل رقم: Rs. ${totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('ایڈوانس کے بغیر قسط:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rs. ${installmentNoAdvance.toStringAsFixed(0)} / ماہانہ',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                if (rawAdvance >= minAdvanceLimit)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('ایڈوانس کے ساتھ قسط:', style: TextStyle(fontSize: 12, color: Colors.green)),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rs. ${installmentWithAdvance.toStringAsFixed(0)} / ماہانہ',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ] else if (_cashPriceController.text.isNotEmpty && !isPriceOverLimit)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Text('درست قیمت درج کریں...', style: TextStyle(color: Colors.grey)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // وارننگ بینر وجیٹ
  Widget _buildWarningBanner(String text, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ایڈمن کنٹرول پینل وجیٹ
  Widget _buildAdminPanel() {
    return Card(
      color: Colors.amber.shade50,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.amber.shade300, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings, color: Colors.amber),
                SizedBox(width: 8),
                Text('بیک اینڈ پرافٹ سیٹنگز', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'بغیر چیک ریٹ %', border: OutlineInputBorder()),
                    onChanged: (val) {
                      setState(() {
                        _noChequeBaseRate = double.tryParse(val) ?? 35.0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'چیک کے ساتھ ریٹ %', border: OutlineInputBorder()),
                    onChanged: (val) {
                      setState(() {
                        _withChequeBaseRate = double.tryParse(val) ?? 25.0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('* نوٹ: ان شرحوں کو تبدیل کرنے سے کسٹمر کے ریٹ فورا بدل جائیں گے۔', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}