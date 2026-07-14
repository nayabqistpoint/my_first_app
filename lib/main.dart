import 'package:flutter/material.dart';

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
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  final List<Map<String, dynamic>> _allCustomers = [
    {
      'name': 'Muhammad Sabir',
      'amount': 50000,
      'isReceivable': true,
      'dueDate': '05 Aug',
      'lastActivity': '14 Jul, 04:30 PM',
      'activityDateTime': DateTime(2026, 7, 14, 16, 30),
      'dueDateTime': DateTime(2026, 8, 5),
    },
    {
      'name': 'Muhammad Aslam',
      'amount': 12000,
      'isReceivable': true,
      'dueDate': '10 Aug',
      'lastActivity': '14 Jul, 02:15 PM',
      'activityDateTime': DateTime(2026, 7, 14, 14, 15),
      'dueDateTime': DateTime(2026, 8, 10),
    },
    {
      'name': 'Ali Raza',
      'amount': 5000,
      'isReceivable': false,
      'dueDate': '20 Jul',
      'lastActivity': '13 Jul, 06:00 PM',
      'activityDateTime': DateTime(2026, 7, 13, 18, 00),
      'dueDateTime': DateTime(2026, 7, 20),
    },
    {
      'name': 'Hafiz Ahmed',
      'amount': 25000,
      'isReceivable': true,
      'dueDate': '01 Aug',
      'lastActivity': '12 Jul, 11:45 AM',
      'activityDateTime': DateTime(2026, 7, 12, 11, 45),
      'dueDateTime': DateTime(2026, 8, 1),
    },
  ];

  String _selectedFilter = 'Default';
  String _searchQuery = '';
  bool? _cardFilterReceivable;
  final TextEditingController _searchController = TextEditingController();

  double get _totalReceivable {
    return _allCustomers
        .where((c) => c['isReceivable'] == true)
        .fold(0.0, (sum, item) => sum + item['amount']);
  }

  double get _totalPayable {
    return _allCustomers
        .where((c) => c['isReceivable'] == false)
        .fold(0.0, (sum, item) => sum + item['amount']);
  }

  List<Map<String, dynamic>> _getFilteredCustomers() {
    List<Map<String, dynamic>> list = List.from(_allCustomers);

    if (_searchQuery.isNotEmpty) {
      list = list.where((c) => c['name'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    if (_cardFilterReceivable != null) {
      list = list.where((c) => c['isReceivable'] == _cardFilterReceivable).toList();
    }

    if (_selectedFilter == 'HighToLow') {
      list.sort((a, b) => b['amount'].compareTo(a['amount']));
    } else if (_selectedFilter == 'LowToHigh') {
      list.sort((a, b) => a['amount'].compareTo(b['amount']));
    } else if (_selectedFilter == 'AZ') {
      list.sort((a, b) => a['name'].compareTo(b['name']));
    } else if (_selectedFilter == 'DueDate') {
      list.sort((a, b) => (a['dueDateTime'] as DateTime).compareTo(b['dueDateTime'] as DateTime));
    } else {
      list.sort((a, b) => (b['activityDateTime'] as DateTime).compareTo(a['activityDateTime'] as DateTime));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredCustomers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nayab Qist Point', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: const Color(0xFF0D47A1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _cardFilterReceivable = (_cardFilterReceivable == false) ? null : false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: _cardFilterReceivable == false ? Border.all(color: Colors.green, width: 3) : null,
                          ),
                          child: Column(
                            children: [
                              const Text('You Will Give', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Rs. ${_totalPayable.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _cardFilterReceivable = (_cardFilterReceivable == true) ? null : true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: _cardFilterReceivable == true ? Border.all(color: Colors.red, width: 3) : null,
                          ),
                          child: Column(
                            children: [
                              const Text('You Will Get', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Rs. ${_totalReceivable.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: const Color(0xFF0D47A1),
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: Row(
                  children: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_alt, color: Colors.white, size: 28),
                      onSelected: (String value) {
                        setState(() {
                          _selectedFilter = value;
                        });
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(value: 'Default', child: Text('Recent Activity')),
                        const PopupMenuItem<String>(value: 'DueDate', child: Text('Sort by Due Date')),
                        const PopupMenuItem<String>(value: 'HighToLow', child: Text('Amount: High to Low')),
                        const PopupMenuItem<String>(value: 'LowToHigh', child: Text('Amount: Low to High')),
                        const PopupMenuItem<String>(value: 'AZ', child: Text('Alphabetical A to Z')),
                      ],
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.black),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search customer...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF0D47A1)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0D47A1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calculate, color: Color(0xFF0D47A1), size: 18),
                            Text('Calculator', style: TextStyle(color: Color(0xFF0D47A1), fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inventory_2, color: Colors.white, size: 18),
                            Text('Stock', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0D47A1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history, color: Color(0xFF0D47A1), size: 18),
                            Text('History', style: TextStyle(color: Color(0xFF0D47A1), fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredList.length,
                  padding: const EdgeInsets.only(bottom: 90),
                  itemBuilder: (context, index) {
                    final customer = filteredList[index];
                    final String firstLetter = customer['name'].isNotEmpty ? customer['name'][0] : '?';

                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rs. ${customer['amount']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: customer['isReceivable'] ? Colors.red.shade700 : Colors.green.shade700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(customer['lastActivity'], style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                              ],
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(customer['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 3),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                                      child: Text('Due: ${customer['dueDate']}', style: const TextStyle(fontSize: 11, color: Color(0xFF0D47A1), fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: customer['isReceivable'] ? Colors.red.shade50 : Colors.green.shade50,
                                  child: Text(
                                    firstLetter,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: customer['isReceivable'] ? Colors.red.shade700 : Colors.green.shade700),
                                  ),
                                ),
                              ],
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
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text('Take Payment', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: PopupMenuButton<String>(
                    onSelected: (value) {},
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Add Customer',
                        child: Row(
                          children: [
                            Icon(Icons.person_add, color: Color(0xFF0D47A1)),
                            SizedBox(width: 8),
                            Text('Add Customer'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Payment Out',
                        child: Row(
                          children: [
                            Icon(Icons.money_off, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Payment Out'),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: const Icon(Icons.add, color: Color(0xFF0D47A1), size: 30),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload, color: Colors.white),
                    label: const Text('Add Sale', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

