import 'package:flutter/material.dart';
import 'sale_purchase.dart';
import 'common/party_selector_widget.dart';
import 'common/item_selector_row_widget.dart';
import 'common/item_detail_widget.dart';
import 'common/discount_widget.dart';
import 'common/transaction_summary_widget.dart';

class SalePage extends StatefulWidget {
  const SalePage({super.key});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _partyPhoneController = TextEditingController();
  final TextEditingController _receivedController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // سیلز کا اپنا لوکل ڈیٹا اور لاجک جو صرف اسی پیج کے اندر رہے گی
  final List<Map<String, dynamic>> _saleItemList = [];
  double _discountValue = 0.0;
  bool _isDiscountPercentage = false;
  int _selectedMode = 1; // 1 مطلب فروخت

  final List<Map<String, String>> _dummyContacts = const [
    {'name': 'علی خان', 'phone': '03001234567'},
    {'name': 'محمد احمد', 'phone': '03219876543'},
    {'name': 'عمران حیدر', 'phone': '03335557788'},
    {'name': 'بلال جنرل سٹور', 'phone': '03124445566'},
  ];

  @override
  void initState() {
    super.initState();
    _receivedController.addListener(_onReceivedAmountChanged);
  }

  void _onReceivedAmountChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _partyNameController.dispose();
    _partyPhoneController.dispose();
    _receivedController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // آئٹم سیভ یا ایڈ کرنے کا خود مختار فنکشن
  void _saveSaleItem({
    int? editIndex,
    required String model,
    required int qty,
    required double purchasePrice,
    required double salePrice,
    required String desc,
    required String imei,
    required String category,
  }) {
    setState(() {
      final newItem = {
        'model': model,
        'qty': qty,
        'purchasePrice': purchasePrice,
        'salePrice': salePrice,
        'desc': desc,
        'imei': imei,
        'category': category,
      };

      if (editIndex != null) {
        _saleItemList[editIndex] = newItem;
      } else {
        _saleItemList.add(newItem);
      }
    });
  }

  // آئٹم ڈیلیٹ کرنے کا فنکشن
  void _deleteSaleItem(int index) {
    setState(() {
      _saleItemList.removeAt(index);
    });
  }

  // ڈسکاؤنٹ سیٹ کرنے کا فنکشن
  void _setDiscount(double value, bool isPercentage) {
    setState(() {
      _discountValue = value;
      _isDiscountPercentage = isPercentage;
    });
  }

  // کلکولیشنز (سب ٹوٹل، ڈسکاؤنٹ اور گرینڈ ٹوٹل)
  double get _subTotal {
    double total = 0.0;
    for (var item in _saleItemList) {
      double price = (item['salePrice'] as double);
      int qty = (item['qty'] as int);
      total += price * qty;
    }
    return total;
  }

  double get _discountAmount {
    if (_isDiscountPercentage) {
      return (_subTotal * _discountValue) / 100;
    }
    return _discountValue;
  }

  double get _grandTotal {
    double finalVal = _subTotal - _discountAmount;
    return finalVal < 0 ? 0 : finalVal;
  }

  // آئٹم ڈیٹیل ڈائیلاگ یا سکرین کھولنے کا طریقہ
  void _openItemDetail({int? editIndex}) {
    final isEditing = editIndex != null;
    final item = isEditing ? _saleItemList[editIndex] : null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailWidget(
          initialModel: isEditing ? item!['model'] : '',
          initialQty: isEditing ? item!['qty'] : 1,
          initialPurchasePrice: isEditing ? item!['purchasePrice'] : 0.0,
          initialSalePrice: isEditing ? item!['salePrice'] : 0.0,
          initialDescription: isEditing ? item!['desc'] : '',
          initialImei: isEditing ? item!['imei'] : '',
          initialCategory: isEditing ? item!['category'] : 'موبائل فون (Mobile Phone)',
          onItemSaved: (model, qty, purchasePrice, salePrice, desc, imei, category) {
            _saveSaleItem(
              editIndex: editIndex,
              model: model,
              qty: qty,
              purchasePrice: purchasePrice,
              salePrice: salePrice,
              desc: desc,
              imei: imei,
              category: category,
            );
          },
        ),
      ),
    );
  }

  void _navigateToSalePurchaseSmoothly() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SalePurchaseForm(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ہیڈر اور ٹوگل
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: const Color(0xFFE53935),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'نایاب قسط پوائنٹ',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 32,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment<int>(
                            value: 0, 
                            label: Text('خرید', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))
                          ),
                          ButtonSegment<int>(
                            value: 1, 
                            label: Text('فروخت', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))
                          ),
                        ],
                        selected: {_selectedMode},
                        onSelectionChanged: (Set<int> newSelection) {
                          setState(() {
                            _selectedMode = newSelection.first;
                          });
                          if (_selectedMode == 0) {
                            _navigateToSalePurchaseSmoothly();
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.selected)) return Colors.white;
                            return Colors.transparent;
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.selected)) return const Color(0xFFE53935);
                            return Colors.white;
                          }),
                          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 10, vertical: 0)),
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // باڈی کا حصہ
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    PartySelectorWidget(
                      nameController: _partyNameController,
                      phoneController: _partyPhoneController,
                      invoiceNo: 'INV-002',
                      currentDate: '23-07-2026',
                      currentTime: '10:00 PM',
                      phoneContacts: _dummyContacts,
                      onNewPartyAdded: (name, phone) {},
                    ),
                    const SizedBox(height: 12),
                    // آئٹم لسٹ کی بنیاد پر وزگیٹ دکھانا
                    if (_saleItemList.isEmpty)
                      ItemSelectorRowWidget(
                        hasItems: false,
                        onTap: () => _openItemDetail(),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _saleItemList.length,
                        itemBuilder: (context, index) {
                          final item = _saleItemList[index];
                          final isLastItem = (index == _saleItemList.length - 1);
                          final qty = item['qty'] as int;
                          final unitPrice = item['salePrice'] as double;

                          final colorDesc = item['desc'] ?? '';
                          final imeiText = (item['imei'] != null && item['imei'].toString().isNotEmpty) 
                              ? ' | IMEI: ${item['imei']}' 
                              : '';
                          final displayDescription = '$colorDesc$imeiText';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ItemSelectorRowWidget(
                              hasItems: true,
                              itemName: item['model'],
                              totalQty: qty,
                              unitPrice: unitPrice,
                              subTotal: qty * unitPrice,
                              description: displayDescription.isNotEmpty ? displayDescription : 'کیٹیگری: ${item['category']}',
                              onEditTap: () => _openItemDetail(editIndex: index),
                              onDeleteTap: () => _deleteSaleItem(index),
                              onPlusTap: isLastItem ? () => _openItemDetail() : null,
                            ),
                          );
                        },
                      ),
                    if (_saleItemList.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      DiscountWidget(
                        onDiscountChanged: (value, isPercentage) {
                          _setDiscount(value, isPercentage);
                        },
                      ),
                      const SizedBox(height: 12),
                      TransactionSummaryWidget(
                        subTotal: _subTotal,
                        discountAmount: _discountAmount,
                        grandTotal: _grandTotal,
                        receivedController: _receivedController,
                        descriptionController: _descriptionController,
                        onAddPhotoPressed: () {},
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}