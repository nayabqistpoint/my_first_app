import 'package:flutter/material.dart';

class BusinessDashboard extends StatefulWidget {
  const BusinessDashboard({super.key});

  @override
  State<BusinessDashboard> createState() => _BusinessDashboardState();
}

class _BusinessDashboardState extends State<BusinessDashboard> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8), // ہلکا نیلا بیک گراؤنڈ
        appBar: AppBar(
          title: const Text(
            'Business Dashboard',
            style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 20),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // ۱۔ فریز پورشن (Sticky Summary): یہ حصہ سکرول کرتے ہوئے اپنی جگہ فریز رہے گا
            _buildStickySummaryCard(),

            // ۲۔ سکرول ایبل پورشن (Scrollable Section): نیچے کا تمام ایریا آرام سے سکرول ہوگا
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    // پہلا حصہ (1/3rd): بینک لسٹنگ کارڈ
                    _buildBankListCard(),
                    const SizedBox(height: 16),

                    // دوسرا حصہ (1/3rd): ایکسپنسز کارڈ (ابھی کے لیے پلیس ہولڈر)
                    _buildExpensesPlaceholder(),
                    const SizedBox(height: 16),

                    // تیسرا حصہ (1/3rd): پرافٹ اینڈ لاس کارڈ اور اس کے بٹن
                    _buildProfitLossPlaceholder(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // فریز کارڈ: جہاں بینک بیلنس اور کیش ان ہینڈ نظر آئے گا
  Widget _buildStickySummaryCard() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Card(
        elevation: 2,
        color: const Color(0xFFE3F2FD), // ہلکا نیلگوں کارڈ
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cash & Bank',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                  ),
                  Text(
                    'See All',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1, color: Colors.blueAccent),
              Row(
                children: [
                  // بینک بیلنس کا باکس
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bank Balance', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('Rs 20,66,713', style: TextStyle(color: Color(0xFF2E7D32), fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // کیش ان ہینڈ کا باکس
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cash In-Hand', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('Rs 150', style: TextStyle(color: Color(0xFF2E7D32), fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بینکوں کی لسٹنگ والا کارڈ
  Widget _buildBankListCard() {
    // ڈمی ڈیٹا بالکل آپ کے اسکرین شاٹ کی طرح
    final List<Map<String, String>> banks = [
      {'name': 'دلشاد دودھی', 'balance': 'Rs 15,50,000'},
      {'name': 'محمد ڈیری', 'balance': 'Rs 1,41,023'},
      {'name': 'SFEL', 'balance': 'Rs 16,601'},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'List of Banks',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: banks.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.black12),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        banks[index]['name']!,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        banks[index]['balance']!,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ایکسپنسز کا کارڈ (خالی جگہ کمنٹ کے ساتھ)
  Widget _buildExpensesPlaceholder() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expenses',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                ),
                Text(
                  'See All',
                  style: TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  '/* یہاں کل کو expenses_section.dart اٹیچ ہوگی */',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // پرافٹ اینڈ لاس کا کارڈ اور دو بٹن
  Widget _buildProfitLossPlaceholder() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profit & Loss',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '/* یہاں کل کو profit_loss_section.dart اٹیچ ہوگی */',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            // دو بٹن پرافٹ اور لاس کو ہینڈل کرنے کے لیے
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // پرافٹ کیلکولیشن کے لیے خالی فنکشن
                    },
                    icon: const Icon(Icons.trending_up, color: Colors.white),
                    label: const Text('پرافٹ رپورٹ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // لاس کیلکولیشن کے لیے خالی فنکشن
                    },
                    icon: const Icon(Icons.trending_down, color: Colors.white),
                    label: const Text('نقصان رپورٹ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}