import 'package:flutter/material.dart';
import 'inventory_page.dart';
import 'customer_ledger_page.dart';
import 'calculator_page.dart';
import 'add_customer_page.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nayab Qist Point',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1),
        useMaterial3: true,
      ),
      home: const CustomerHomePage(),
    );
  }
}

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final List<Map<String, dynamic>> _customers = [
    {
      'name': 'احمد کریانہ اسٹور Y11D',
      'phone': '03001234567',
      'balance': 31000,
      'dueDate': '01 Jun 26',
      'entries': [
        {'date': 'Fri, 03 Jul 26', 'type': 'got', 'amount': 15000, 'details': 'قسط وصولی', 'balanceAfter': 31000},
        {'date': 'Sat, 13 Jun 26', 'type': 'got', 'amount': 10000, 'details': 'قسط وصولی', 'balanceAfter': 46000},
        {'date': 'Thu, 19 Mar 26', 'type': 'gave', 'amount': 64000, 'details': 'Y11D قسط 500 روزانہ', 'balanceAfter': 64000},
      ]
    },
    {
      'name': 'محمد اشرف',
      'phone': '03019876543',
      'balance': 18000,
      'dueDate': '15 Jul 26',
      'entries': [
        {'date': 'Mon, 01 Jul 26', 'type': 'got', 'amount': 5000, 'details': 'قسط وصولی', 'balanceAfter': 18000},
        {'date': 'Sat, 10 Jun 26', 'type': 'gave', 'amount': 23000, 'details': 'سام سنگ A14 ادھار', 'balanceAfter': 23000},
      ]
    },
    {'name': 'علی رضا (فون ایکسچینج)', 'phone': '03021234567', 'balance': 45000, 'dueDate': '20 Jul 26', 'entries': []},
    {'name': 'طارق محمود', 'phone': '03055556666', 'balance': 12000, 'dueDate': '25 Jul 26', 'entries': []},
    {'name': 'عدنان موبائل شاپ', 'phone': '03137778888', 'balance': 85000, 'dueDate': '30 Jul 26', 'entries': []},
    {'name': 'سجاد حسین بٹ', 'phone': '03214567890', 'balance': 22000, 'dueDate': '05 Aug 26', 'entries': []},
    {'name': 'عرفان الیکٹرانکس', 'phone': '03009876543', 'balance': 60000, 'dueDate': '10 Aug 26', 'entries': []},
    {'name': 'بلال جنرل سٹور', 'phone': '03451234567', 'balance': 15000, 'dueDate': '12 Aug 26', 'entries': []},
    {'name': 'حمزہ چوہدری', 'phone': '03335554443', 'balance': 35000, 'dueDate': '18 Aug 26', 'entries': []},
    {'name': 'قاسم علی', 'phone': '03123456789', 'balance': 9000, 'dueDate': '22 Aug 26', 'entries': []},
    {'name': 'یاسر فاروق', 'phone': '03041112223', 'balance': 27000, 'dueDate': '25 Aug 26', 'entries': []},
    {'name': 'عمران خان (درزی)', 'phone': '03227778889', 'balance': 14000, 'dueDate': '28 Aug 26', 'entries': []},
    {'name': 'زاہد محمود کلوتھ ہاؤس', 'phone': '03069998887', 'balance': 52000, 'dueDate': '01 Sep 26', 'entries': []},
    {'name': 'نعمان شاہد', 'phone': '03154445556', 'balance': 19500, 'dueDate': '05 Sep 26', 'entries': []},
    {'name': 'شاہد اقبال فینسی ہاؤس', 'phone': '03013332221', 'balance': 41000, 'dueDate': '10 Sep 26', 'entries': []},
  ];

  int get _totalYouWillGet {
    return _customers.fold(0, (sum, item) => sum + (item['balance'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نایاپ قسط پوائنٹ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF0D47A1),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);

            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddCustomerPage()),
            );
            
            if (!mounted) return;

            if (result != null && result is Map<String, dynamic>) {
              setState(() {
                _customers.add(result);
              });
              messenger.showSnackBar(
                SnackBar(
                  content: Text('${result['name']} کامیابی سے شامل کر دیا گیا!'), 
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          label: const Text('نیا کسٹمر', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.person_add, color: Colors.white),
          backgroundColor: const Color(0xFF0D47A1),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF0D47A1),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('کل وصول طلب رقم: Rs. $_totalYouWillGet'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.green.shade50,
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Column(
                            children: [
                              const Text('آپ کو ملیں گے', style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Rs. $_totalYouWillGet', style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 17)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('آپ نے فی الحال کسی کے پیسے نہیں دینے'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.red.shade50,
                        elevation: 3,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Column(
                            children: [
                              Text('آپ نے دینے ہیں', style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('Rs. 0', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 17)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'کسٹمر تلاش کریں...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.filter_list, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _quickActionButton(
                        icon: Icons.calculate,
                        label: 'کیلکولیٹر',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CalculatorPage()),
                          );
                        },
                      ),
                      _quickActionButton(
                        icon: Icons.inventory_2,
                        label: 'اسٹاک انوینٹری',
                        color: const Color(0xFF0D47A1),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const InventoryPage()),
                          );
                        },
                      ),
                      _quickActionButton(
                        icon: Icons.history,
                        label: 'روزنامچہ / ہسٹری',
                        color: Colors.teal,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _customers.length,
                itemBuilder: (context, index) {
                  final customer = _customers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomerLedgerPage(customerData: customer),
                          ),
                        );
                        if (!mounted) return;
                        setState(() {});
                      },
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF0D47A1),
                        child: Text(
                          customer['name'].isNotEmpty ? customer['name'][0] : 'C',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(customer['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: Text('فون: ${customer['phone']} | وعدہ: ${customer['dueDate']}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs. ${customer['balance']}',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const Text('ملیں گے', style: TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(76)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}