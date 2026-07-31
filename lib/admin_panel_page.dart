import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final PageController _pageController = PageController(initialPage: 1);
  int _currentIndex = 1;

  // ہر ریکویسٹ کے لیے الگ قیمت کا کنٹرولر
  final Map<String, TextEditingController> _priceControllers = {};

  // ہر پیج کے اندر فلٹر کو کنٹرول کرنے کے لیے (کلیدیں ہوں گی: 'approved', 'pending', 'completed')
  // فلٹر کی اقسام: 'all', 'signup', 'purchase', 'both'
  final Map<String, String> _pageFilters = {
    'approved': 'all',
    'pending': 'all',
    'completed': 'all',
  };

  final List<Map<String, dynamic>> _requests = [
    {
      'id': '1',
      'status': 'pending',
      'requestType': 'سائن اپ + پرچیز',
      'filterKey': 'both',
      'name': 'محمد احمد',
      'fatherName': 'محمد علی',
      'phone': '03001234567',
      'cnic': '36302-1234567-1',
      'address': 'مین بازار، قایم پور',
      'mobileName': 'Samsung Galaxy A15',
      'isManualMode': true,
      'cashPrice': '45000',
      'advance': '10000',
      'installment': '5000',
      'packageName': '6 ماہ قسط پیکج',
      'hasGuarantor': true,
      'guarantorName': 'علی حسن',
      'guarantorPhone': '03019876543',
      'guarantorCnic': '36302-7654321-2',
      'isExpanded': false,
    },
    {
      'id': '2',
      'status': 'approved',
      'requestType': 'صرف سائن اپ',
      'filterKey': 'signup',
      'name': 'فاطمہ بی بی',
      'fatherName': 'احمد حسن',
      'phone': '03029876543',
      'cnic': '36302-9876543-3',
      'address': 'محلہ عثمانیہ، قایم پور',
      'mobileName': null,
      'hasGuarantor': false,
      'isExpanded': false,
    },
    {
      'id': '3',
      'status': 'pending',
      'requestType': 'صرف پرچیز',
      'filterKey': 'purchase',
      'name': 'عثمان غنی',
      'fatherName': 'عبداللہ',
      'phone': '03051112233',
      'cnic': '36302-3332211-1',
      'address': 'بستی ملوک روڈ، قایم پور',
      'mobileName': 'Vivo Y18',
      'isManualMode': false,
      'cashPrice': '0',
      'advance': '5000',
      'installment': '4000',
      'packageName': '3 ماہ قسط پیکج',
      'hasGuarantor': true,
      'guarantorName': 'طارق محمود',
      'guarantorPhone': '03059998877',
      'guarantorCnic': '36302-9998877-9',
      'isExpanded': false,
    },
    {
      'id': '4',
      'status': 'completed',
      'requestType': 'صرف پرچیز',
      'filterKey': 'purchase',
      'name': 'محمد بلال',
      'fatherName': 'اللہ رکھا',
      'phone': '03035554433',
      'cnic': '36302-5554433-5',
      'address': 'لاری اڈہ، قایم پور',
      'mobileName': 'Xiaomi Redmi Note 13',
      'isManualMode': false,
      'cashPrice': '0',
      'advance': '15000',
      'installment': '6000',
      'packageName': '12 ماہ قسط پیکج',
      'hasGuarantor': true,
      'guarantorName': 'عمران خان',
      'guarantorPhone': '03001112233',
      'guarantorCnic': '36302-1112233-4',
      'isExpanded': false,
    },
  ];

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  Future<void> _openWhatsApp(String phone, String message) async {
    String formattedPhone = phone.startsWith('0') ? '92${phone.substring(1)}' : phone;
    final Uri whatsappUri = Uri.parse('https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}');
    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: const Color(0xFFE53935),
          title: const Text("ایڈمن پینل - موصولہ درخواستیں", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // اوپر فکسڈ کیپسول ٹیبز (منظور شدہ، پینڈنگ، مکمل شدہ)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(child: Center(child: _buildCapsuleTab(0, 'منظور شدہ'))),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Center(child: _buildCapsuleTab(1, 'پینڈنگ ریکویسٹس')),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Center(child: _buildCapsuleTab(2, 'مکمل شدہ'))),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.grey),

            // نیچے پیج ویو
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  _buildPageContent('approved'),
                  _buildPageContent('pending'),
                  _buildPageContent('completed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ہر پیج کا لے آؤٹ جس کے اندر سب سے اوپر فلٹر بار اور نیچے لسٹ ہوگی
  Widget _buildPageContent(String status) {
    String currentFilter = _pageFilters[status]!;

    // پہلے مین سٹیٹس کے مطابق ریکویسٹس فلٹر کریں
    var statusFiltered = _requests.where((req) => req['status'] == status).toList();

    // اب اندرونی سب-فلٹر (آل، سائن اپ، پرچیز، دونوں) کے مطابق فلٹر کریں
    final filteredRequests = statusFiltered.where((req) {
      if (currentFilter == 'all') return true;
      return req['filterKey'] == currentFilter;
    }).toList();

    return Column(
      children: [
        // **ان-پیج فلٹر بار (فوراً نظر آنے والے تمام آپشنز)**
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(child: _buildSubFilterChip(status, 'all', 'تمام')),
              const SizedBox(width: 6),
              Expanded(child: _buildSubFilterChip(status, 'purchase', 'صرف پرچیز')),
              const SizedBox(width: 6),
              Expanded(child: _buildSubFilterChip(status, 'signup', 'صرف سائن اپ')),
              const SizedBox(width: 6),
              Expanded(child: _buildSubFilterChip(status, 'both', 'دونوں مکس')),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.grey),

        // لسٹ ویو
        Expanded(
          child: filteredRequests.isEmpty
              ? const Center(
                  child: Text("اس زمرے یا فلٹر میں کوئی درخواست موجود نہیں ہے", style: TextStyle(color: Colors.grey, fontSize: 13)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: filteredRequests.length,
                  itemBuilder: (context, index) {
                    final req = filteredRequests[index];
                    bool isExpanded = req['isExpanded'];
                    String reqId = req['id'];

                    if (!_priceControllers.containsKey(reqId)) {
                      _priceControllers[reqId] = TextEditingController();
                    }
                    final priceController = _priceControllers[reqId]!;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 2,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.red.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                req['isExpanded'] = !isExpanded;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.person, color: Color(0xFFE53935)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(req['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: const Color(0xFFE53935), width: 1),
                                              ),
                                              child: Text(
                                                req['requestType'], 
                                                style: const TextStyle(fontSize: 10, color: Color(0xFFE53935), fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          "فون: ${req['phone']} ${req['mobileName'] != null ? ' | ماڈل: ${req['mobileName']} (${req['isManualMode'] == true ? 'مینول - نقد: ${req['cashPrice']}' : 'بائے اسٹاک'})' : ' | (صرف سائن اپ)'}",
                                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey[600]),
                                ],
                              ),
                            ),
                          ),

                          if (isExpanded) ...[
                            const Divider(height: 1, color: Colors.grey),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("■ کسٹمر کی معلومات", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE53935), fontSize: 14)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Icon(Icons.camera_alt, size: 30, color: Colors.grey),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("نام: ${req['name']} (والد: ${req['fatherName']})", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 3),
                                              InkWell(
                                                onTap: () => _makePhoneCall(req['phone']),
                                                child: Text("فون نمبر: ${req['phone']} 📞 (کال کریں)", style: const TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.bold)),
                                              ),
                                              const SizedBox(height: 3),
                                              Text("شناختی کارڈ: ${req['cnic']}", style: const TextStyle(fontSize: 12)),
                                              const SizedBox(height: 3),
                                              Text("پتہ: ${req['address']}", style: const TextStyle(fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (req['mobileName'] != null) ...[
                                    const SizedBox(height: 12),
                                    const Text("■ منتخب کردہ موبائل اور قسط پیکج", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE53935), fontSize: 14)),
                                    const SizedBox(height: 6),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("موبائل ماڈل: ${req['mobileName']}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 3),
                                          Text("خریداری کا موڈ: ${req['isManualMode'] == true ? 'مینول (کسٹمر کی درج کردہ نقد قیمت: ${req['cashPrice']} روپے)' : 'دستیاب سٹاک سے (بائے اسٹاک)'}", style: const TextStyle(fontSize: 12)),
                                          
                                          if (req['isManualMode'] == true) ...[
                                            const SizedBox(height: 8),
                                            TextField(
                                              controller: priceController,
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText: "مارکیٹ تصدیق شدہ نقد قیمت درج کریں (پرائس مس میچ کے لیے)",
                                                hintText: "مثلاً 50000",
                                                isDense: true,
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                              ),
                                            ),
                                          ],

                                          const SizedBox(height: 3),
                                          Text("پیکج: ${req['packageName']} | ماہانہ قسط: ${req['installment']} روپے", style: const TextStyle(fontSize: 12)),
                                          const SizedBox(height: 3),
                                          Text("جمع کروایا جانے والا ایڈوانس: ${req['advance']} روپے", style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],

                                  if (req['hasGuarantor'] == true) ...[
                                    const SizedBox(height: 12),
                                    const Text("■ ضامن کی معلومات", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE53935), fontSize: 14)),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Icon(Icons.person_outline, size: 25, color: Colors.grey),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("ضامن کا نام: ${req['guarantorName']}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 3),
                                                InkWell(
                                                  onTap: () => _makePhoneCall(req['guarantorPhone']),
                                                  child: Text("فون: ${req['guarantorPhone']} 📞", style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
                                                ),
                                                const SizedBox(height: 3),
                                                Text("شناختی کارڈ: ${req['guarantorCnic']}", style: const TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 15),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _openWhatsApp(
                                              req['phone'],
                                              "السلام علیکم ${req['name']}! نایاب قسط پوائنٹ کی طرف سے آپ کو مطلع کیا جاتا ہے کہ آپ کی درخواست منظور کر لی گئی ہے۔ براہ کرم اپنے اصل شناختی کارڈ اور ضروری قانونی دستاویزات کے ساتھ دکان تشریف لائیں۔",
                                            );
                                          },
                                          icon: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                          label: const Text("منظور کریں", style: TextStyle(color: Colors.white, fontSize: 12)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            String verifiedPrice = priceController.text.trim();
                                            String objectionMessage;

                                            if (req['isManualMode'] == true && verifiedPrice.isNotEmpty) {
                                              objectionMessage = "محترم ${req['name']}! آپ کی درخواست میں درج کردہ موبائل قیمت اور مارکیٹ کی تصدیق شدہ اصل قیمت میں فرق (Price Mismatch) ہے۔ آپ نے نقد قیمت ${req['cashPrice']} لکھی تھی جبکہ مارکیٹ تصدیق شدہ اصل قیمت $verifiedPrice روپے ہے۔ لہذا آپ کی درخواست پر اعتراض لگایا گیا ہے۔ براہ کرم اس درست قیمت کے حساب سے اپنی ریکویسٹ اپ ڈیٹ کریں یا دکان تشریف لائیں۔";
                                            } else {
                                              objectionMessage = "محترم ${req['name']}! آپ کی درخواست ناگزیر وجوہات (کاغذات کی کمی یا شرائط پوری نہ ہونے) کی وجہ سے فی الحال واپس / مسترد کی جاتی ہے۔";
                                            }

                                            _openWhatsApp(req['phone'], objectionMessage);
                                          },
                                          icon: const Icon(Icons.cancel, color: Colors.white, size: 18),
                                          label: const Text("اعتراض / پرائس مس میچ", style: TextStyle(color: Colors.white, fontSize: 11)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFE53935),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // اوپر والے مین کیپسول ٹیبز کے لیے
  Widget _buildCapsuleTab(int index, String title) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE53935).withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE53935), 
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE53935),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // نیچے ہر پیج کے اندر چھوٹے سب-فلٹر بٹنوں (Chips) کے لیے
  Widget _buildSubFilterChip(String pageStatus, String filterKey, String label) {
    bool isSelected = _pageFilters[pageStatus] == filterKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _pageFilters[pageStatus] = filterKey;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE53935) : Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey[800],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}