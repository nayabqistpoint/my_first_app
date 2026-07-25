import 'package:flutter/material.dart';
import 'sale_controller.dart';
import 'sale_purchase.dart';
import '../controllers/item_controller.dart';
import '../controllers/customer_controller.dart';
import 'common/party_selector_widget.dart';
import 'common/item_selector_row_widget.dart';
import 'common/discount_widget.dart';
import 'common/transaction_summary_widget.dart';
import 'common/sale_purchase_toggle_widget.dart';
import '../../dashboard/widgets/source_selecter.dart';
import 'common/item_detail_widget.dart';

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

  String? _selectedBankSource;
  double _cashAmount = 0.0;
  double _bankAmount = 0.0;

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

  void _openQuickSellItem({int? editIndex}) {
    final isEditing = editIndex != null;
    final itemList = saleController.itemList;
    final item = isEditing ? itemList[editIndex] : null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailWidget(
          isSaleMode: true,
          initialModel: isEditing ? item!['model'] : '',
          initialQty: isEditing ? item!['qty'] : 1,
          initialPurchasePrice: isEditing ? item!['purchasePrice'] : 0.0,
          initialSalePrice: isEditing ? item!['salePrice'] : 0.0,
          initialDescription: isEditing ? item!['desc'] : '',
          initialImei: isEditing ? item!['imei'] : '',
          initialCategory: isEditing ? item!['category'] : 'موبائل فون (Mobile Phone)',
          initialSupplierName: isEditing ? (item!['supplier'] ?? '') : '',
          onItemSaved: (model, qty, purchasePrice, salePrice, desc, imei, category, supplierName) {
            saleController.saveItem(
              editIndex: editIndex,
              model: model,
              qty: qty,
              purchasePrice: purchasePrice,
              salePrice: salePrice,
              desc: desc,
              imei: imei,
              category: category,
              supplier: supplierName,
              color: desc,
            );
          },
        ),
      ),
    );
  }

  void _onSaveAndSharePressed() {
    if (saleController.itemList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کم از کم ایک آئٹم شامل کرنا ضروری ہے')),
      );
      return;
    }

    // یہاں آپ _selectedBankSource, _cashAmount اور _bankAmount کو آگے پے منٹ یا لیجر میں پاس کر سکتے ہیں
    debugPrint('Selected Bank: $_selectedBankSource, Cash: $_cashAmount, Bank: $_bankAmount');

    for (var item in saleController.itemList) {
      itemController.reduceItemStock(
        name: item['model'] ?? 'نامعلوم',
        imei: item['imei'] ?? '',
        quantityToSubtract: item['qty'] ?? 1,
      );
    }

    final partyName = _partyNameController.text.trim();
    final partyPhone = _partyPhoneController.text.trim();

    if (partyName.isNotEmpty) {
      final grandTotal = saleController.grandTotal;
      final receivedAmount = double.tryParse(_receivedController.text) ?? 0.0;
      final balance = grandTotal - receivedAmount;
      final String transactionType = balance >= 0 ? 'get' : 'give';

      customerController.addOrUpdateCustomer(
        name: partyName,
        phone: partyPhone.isNotEmpty ? partyPhone : 'نامعلوم',
        amount: balance.abs(),
        type: transactionType, 
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : 'موبائل فون فروخت (Sale)',
      );
    }

    saleController.clearSale();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سیل انٹری کامیابی سے محفوظ اور اسٹاک اپڈیٹ کر دیا گیا ہے')),
    );
    Navigator.pop(context);
  }

  void _navigateToPurchasePageSmoothly() {
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
    return ListenableBuilder(
      listenable: saleController,
      builder: (context, child) {
        final itemList = saleController.itemList;
        final grandTotal = saleController.grandTotal;
        double currentReceivedAmount = double.tryParse(_receivedController.text) ?? 0.0;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: const Color(0xFFE53935),
                  child: Row(
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'نایاب قسط پوائنٹ - فروخت',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SalePurchaseToggleWidget(
                        isSaleSelected: true,
                        onPurchaseTap: () {
                          _navigateToPurchasePageSmoothly();
                        },
                        onSaleTap: () {},
                      ),
                    ],
                  ),
                ),
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
                          currentTime: '4:37 AM',
                          phoneContacts: _dummyContacts,
                          onNewPartyAdded: (name, phone) {
                            _partyNameController.text = name;
                            _partyPhoneController.text = phone;
                          },
                        ),
                        const SizedBox(height: 12),
                        if (itemList.isEmpty)
                          ItemSelectorRowWidget(
                            hasItems: false,
                            onTap: () => _openQuickSellItem(),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: itemList.length,
                            itemBuilder: (context, index) {
                              final item = itemList[index];
                              final isLastItem = (index == itemList.length - 1);
                              final qty = item['qty'] as int? ?? 1;
                              final unitPrice = (item['salePrice'] as num?)?.toDouble() ?? 0.0;
                              final colorDesc = item['desc'] ?? '';
                              final imeiText = (item['imei'] != null && item['imei'].toString().isNotEmpty) 
                                  ? ' | IMEI: ${item['imei']}' 
                                  : '';
                              final displayDescription = '$colorDesc$imeiText';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ItemSelectorRowWidget(
                                  hasItems: true,
                                  itemName: item['model'] ?? 'نامعلوم',
                                  totalQty: qty,
                                  unitPrice: unitPrice,
                                  subTotal: qty * unitPrice,
                                  description: displayDescription.isNotEmpty ? displayDescription : 'کیٹیگری: ${item['category'] ?? 'جنرل'}',
                                  onEditTap: () => _openQuickSellItem(editIndex: index),
                                  onDeleteTap: () => saleController.deleteItem(index),
                                  onPlusTap: isLastItem ? () => _openQuickSellItem() : null,
                                ),
                              );
                            },
                          ),
                        if (itemList.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          DiscountWidget(
                            onDiscountChanged: (value, isPercentage) {
                              saleController.setDiscount(value, isPercentage);
                            },
                          ),
                          const SizedBox(height: 12),
                          TransactionSummaryWidget(
                            subTotal: saleController.subTotal,
                            discountAmount: saleController.discountAmount,
                            grandTotal: grandTotal,
                            receivedController: _receivedController,
                            descriptionController: _descriptionController,
                            onAddPhotoPressed: () {},
                          ),
                          const SizedBox(height: 12),
                          SourceSelecter(
                            defaultAmount: currentReceivedAmount,
                            onSplitPaymentChanged: (primaryBankSource, totalCash, totalBank, detailedSplits) {
                              setState(() {
                                _selectedBankSource = primaryBankSource;
                                _cashAmount = totalCash;
                                _bankAmount = totalBank;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE53935),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _onSaveAndSharePressed,
                              icon: const Icon(Icons.check_circle, size: 18),
                              label: const Text(
                                "سیل مکمل کریں اور محفوظ کریں",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
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
      },
    );
  }
}