import 'package:flutter/material.dart';
import 'dashboard/business_dashboard.dart'; // بزنس ڈیش بورڈ کی امپورٹ
import 'inventory_page.dart';
import 'customer_ledger_page.dart';
import 'calculator_page.dart';
import 'add_customer_page.dart'; 
import 'history_page.dart';

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
  List<Map<String, dynamic>> _customers = [
    {
      'name': 'احمد کریانہ اسٹور Y11D',
      'phone': '03001234567',
      'balance': 31000,
      'dueDate': '01 Jun 26',
      'group': 'ہول سیلر',
      'entries': [
        {'date': 'Fri, 03 Jul 26', 'type': 'got', 'amount': 15000, 'details': 'قسط وصولی', 'timestamp': 1719950400000},
        {'date': 'Sat, 13 Jun 26', 'type': 'got', 'amount': 10000, 'details': 'قسط وصولی', 'timestamp': 1718222400000},
        {'date': 'Thu, 19 Mar 26', 'type': 'gave', 'amount': 56000, 'details': 'Y11D قسط 500 روزانہ', 'timestamp': 1710792000000},
      ]
    },
    {
      'name': 'محمد اشرف',
      'phone': '03019876543',
      'balance': 18000,
      'dueDate': '15 Jul 26',
      'group': 'ریٹیلر',
      'entries': [
        {'date': 'Mon, 01 Jul 26', 'type': 'got', 'amount': 5000, 'details': 'قسط وصولی', 'timestamp': 1719777600000},
        {'date': 'Sat, 10 Jun 26', 'type': 'gave', 'amount': 23000, 'details': 'سام سنگ A14 ادھار', 'timestamp': 1717963200000},
      ]
    },
    {'name': 'علی رضا (فون ایکسچینج)', 'phone': '03021234567', 'balance': 45000, 'dueDate': '20 Jul 26', 'group': 'لوکل فیملی', 'entries': []},
    {'name': 'طارق محمود', 'phone': '03055556666', 'balance': 12000, 'dueDate': '25 Jul 26', 'group': 'ریٹیلر', 'entries': []},
    {'name': 'عدنان موبائل شاپ', 'phone': '03137778888', 'balance': 85000, 'dueDate': '30 Jul 26', 'group': 'ہول سیلر', 'entries': []},
    {'name': 'سجاد حسین بٹ', 'phone': '03214567890', 'balance': 22000, 'dueDate': '05 Aug 26', 'group': 'لوکل فیملی', 'entries': []},
    {'name': 'عرفان الیکٹرانکس', 'phone': '03009876543', 'balance': 60000, 'dueDate': '10 Aug 26', 'group': 'ہول سیلر', 'entries': []},
  ];

  String _searchQuery = '';
  String _sortBy = 'none';
  String _selectedGroup = 'All';

  int get _totalOut {
    return _customers.fold<int>(0, (sum, item) {
      final b = (item['balance'] as num?)?.toInt() ?? 0;
      return b > 0 ? sum + b : sum;
    });
  }

  int get _totalIn {
    return _customers.fold<int>(0, (sum, item) {
      final b = (item['balance'] as num?)?.toInt() ?? 0;
      return b < 0 ? sum + b.abs() : sum;
    });
  }

  int _getLatestActivityTime(Map<String, dynamic> customer) {
    final entries = customer['entries'] as List<dynamic>? ?? [];
    if (entries.isEmpty) return 0;
    
    int maxTime = 0;
    for (var entry in entries) {
      final t = (entry['timestamp'] as num?)?.toInt() ?? 0;
      if (t > maxTime) maxTime = t;
    }
    return maxTime;
  }

  List<Map<String, dynamic>> get _filteredCustomers {
    List<Map<String, dynamic>> list = List.from(_customers);

    if (_searchQuery.isNotEmpty) {
      list = list.where((c) {
        final name = c['name'].toString().toLowerCase();
        final phone = c['phone'].toString().toLowerCase();
        return name.contains(_searchQuery.toLowerCase()) || phone.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedGroup != 'All') {
      list = list.where((c) => (c['group'] ?? 'ڈیفالٹ') == _selectedGroup).toList();
    }

    if (_sortBy == 'az') {
      list.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
    } else if (_sortBy == 'za') {
      list.sort((a, b) => b['name'].toString().compareTo(a['name'].toString()));
    } else if (_sortBy == 'highToLow') {
      list.sort((a, b) => ((b['balance'] as num?)?.toInt() ?? 0).compareTo((a['balance'] as num?)?.toInt() ?? 0));
    } else if (_sortBy == 'lowToHigh') {
      list.sort((a, b) => ((a['balance'] as num?)?.toInt() ?? 0).compareTo((b['balance'] as num?)?.toInt() ?? 0));
    } else if (_sortBy == 'dueDate') {
      list.sort((a, b) => a['dueDate'].toString().compareTo(b['dueDate'].toString()));
    } else {
      list.sort((a, b) => _getLatestActivityTime(b).compareTo(_getLatestActivityTime(a)));
    }

    return list;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'لسٹ ترتیب دیں',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('حالیہ ایکٹیویٹی (ریسنٹ ٹرانزیکشن)'),
                  trailing: _sortBy == 'none' ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    setState(() => _sortBy = 'none');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha),
                  title: const Text('الف سے ی (A to Z)'),
                  trailing: _sortBy == 'az' ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    setState(() => _sortBy = 'az');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha),
                  title: const Text('ی سے الف (Z to A)'),
                  trailing: _sortBy == 'za' ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    setState(() => _sortBy = 'za');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.trending_down),
                  title: const Text('زیادہ رقم پہلے (بڑی سے چھوٹی)'),
                  trailing: _sortBy == 'highToLow' ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    setState(() => _sortBy = 'highToLow');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.trending_up),
                  title: const Text('کم رقم پہلے (چھوٹی سے بڑی)'),
                  trailing: _sortBy == 'lowToHigh' ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    setState(() => _sortBy = 'lowToHigh');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: const Text('وعدے کی تاریخ کے مطابق'),
                  trailing: _sortBy == 'dueDate' ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    setState(() => _sortBy = 'dueDate');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredCustomers;

    // یہاں سوائپ کے لیے GestureDetector کو باہر لپیٹ دیا گیا ہے، باقی پورا کوڈ ہوبہو آپ کا ہی ہے
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // دائیں طرف سے بائیں طرف سوائپ کرنے پر بزنس ڈیش بورڈ پر جائے گا
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const BusinessDashboard(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(-1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        }
      },
      child: Directionality(
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
                  result['timestamp'] = DateTime.now().millisecondsSinceEpoch;
                  result['entries'] = [];
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
                      child: Card(
                        color: Colors.red.shade50,
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Column(
                            children: [
                              const Text('کل باہر رقم (آؤٹ)', style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Rs. $_totalOut', style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 17)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        color: Colors.green.shade50,
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Column(
                            children: [
                              const Text('کل جمع رقم (اِن)', style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Rs. $_totalIn', style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 17)),
                            ],
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
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
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
                          onPressed: _showFilterBottomSheet,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'ہول سیلر', 'ریٹیلر', 'لوکل فیملی'].map((group) {
                          final isSelected = _selectedGroup == group;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ChoiceChip(
                              label: Text(group),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedGroup = selected ? group : 'All';
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
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
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HistoryPage(
                                  customers: _customers,
                                  onUpdateCustomers: (updatedList) {
                                    _customers = updatedList;
                                  },
                                ),
                              ),
                            );
                            if (!mounted) return;
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: filteredList.isEmpty
                    ? const Center(child: Text('کوئی کسٹمر نہیں ملا!', style: TextStyle(fontWeight: FontWeight.bold)))
                    : ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final customer = filteredList[index];
                          final customerIndexInMainList = _customers.indexWhere((c) => c['phone'] == customer['phone']);
                          final bal = (customer['balance'] as num?)?.toInt() ?? 0;

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            elevation: 1.5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustomerLedgerPage(
                                      customerData: customer,
                                      onUpdateCustomer: (updatedCustomer) {
                                        setState(() {
                                          if (customerIndexInMainList != -1) {
                                            _customers[customerIndexInMainList] = updatedCustomer;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                );
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
                                    'Rs. ${bal.abs()}',
                                    style: TextStyle(
                                      color: bal >= 0 ? Colors.red : Colors.green, 
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 15
                                    ),
                                  ),
                                  Text(
                                    bal >= 0 ? 'آؤٹ' : 'اِن', 
                                    style: const TextStyle(color: Colors.grey, fontSize: 10)
                                  ),
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