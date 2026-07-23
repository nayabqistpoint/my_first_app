import 'package:flutter/material.dart';
import 'sale_purchase.dart';
import 'sale_purchase_controller.dart'; // کنٹرولر کی فائل کو امپورٹ کریں
import 'common/party_selector_widget.dart';
import 'common/item_selector_row_widget.dart';
import 'common/item_detail_widget.dart';
import 'common/discount_widget.dart';
import 'common/transaction_summary_widget.dart';
import 'package:my_first_app/dashboard/widgets/source_selecter.dart';

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

  final List<Map<String, String>> _dummyContacts = const [
    {'name': 'علی خان', 'phone': '03001234567'},
    {'name': 'محمد احمد', 'phone': '03219876543'},
    {'name': 'عمران حیدر', 'phone': '03335557788'},
    {'name': 'بلال جنرل سٹور', 'phone': '03124445566'},
  ];

  @override
  void initState() {
    super.initState();
    // پیج کھلتے ہی کنٹرولر کو بتائیں کہ اب ہم فروخت (Sale) موڈ یعنی 1 میں ہیں
    salePurchaseController.setMode(1);

    // یوزر جب وصولی والے خانے میں رقم لکھے تو سکرین فورا اپ ڈیٹ ہو
    _receivedController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _partyNameController.dispose();
    _partyPhoneController.dispose();
    _receivedController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // خرید والے پیج کی طرز پر effective amount معلوم کرنے کا فنکشن
  double get _effectiveAmountForSource {
    if (_receivedController.text.isNotEmpty) {
      double? val = double.tryParse(_receivedController.text);
      if (val != null) {
        return val;
      }
    }
    return salePurchaseController.grandTotal;
  }

  void _openItemDetail({int? editIndex}) {
    final isEditing = editIndex != null;
    final currentList = salePurchaseController.itemList;
    final item = isEditing ? currentList[editIndex] : null;

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
            // براہ راست کنٹرولر کے اندر سیو کریں تاکہ ڈیٹا محفوظ رہے
            salePurchaseController.saveItem(
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

  void _switchToPurchase() {
    // خرید موڈ میں جانے سے پہلے کنٹرولر کا موڈ 0 کر دیں
    salePurchaseController.setMode(0);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SalePurchaseForm()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder کے ذریعے کنٹرولر کو سنیں تاکہ ڈیٹا بدلنے پر سکرین فورا اپ ڈیٹ ہو
    return AnimatedBuilder(
      animation: salePurchaseController,
      builder: (context, child) {
        final saleItems = salePurchaseController.itemList;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  color: const Color(0xFFE53935),
                  child: Row(
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'نایاب قسط پوائنٹ',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        height: 34,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: _switchToPurchase,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'خرید',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'فروخت',
                                style: TextStyle(color: Color(0xFFE53935), fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
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
                          currentTime: '10:05 PM',
                          phoneContacts: _dummyContacts,
                          onNewPartyAdded: (name, phone) {},
                        ),
                        const SizedBox(height: 12),
                        if (saleItems.isEmpty)
                          ItemSelectorRowWidget(
                            hasItems: false,
                            onTap: () => _openItemDetail(),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: saleItems.length,
                            itemBuilder: (context, index) {
                              final item = saleItems[index];
                              final isLastItem = (index == saleItems.length - 1);
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
                                  onDeleteTap: () => salePurchaseController.deleteItem(index),
                                  onPlusTap: isLastItem ? () => _openItemDetail() : null,
                                ),
                              );
                            },
                          ),
                        if (saleItems.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          DiscountWidget(
                            onDiscountChanged: (value, isPercentage) {
                              salePurchaseController.setDiscount(value, isPercentage);
                            },
                          ),
                          const SizedBox(height: 12),
                          TransactionSummaryWidget(
                            subTotal: salePurchaseController.subTotal,
                            discountAmount: salePurchaseController.discountAmount,
                            grandTotal: salePurchaseController.grandTotal,
                            receivedController: _receivedController,
                            descriptionController: _descriptionController,
                            onAddPhotoPressed: () {},
                          ),
                          const SizedBox(height: 12),
                          SourceSelecter(
                            defaultAmount: _effectiveAmountForSource,
                            onSplitPaymentChanged: (primaryBankSource, totalCash, totalBank, detailedSplits) {},
                          ),
                          const SizedBox(height: 16),
                          // محفوظ کریں اور شیئر کریں کا بٹن
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE53935),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                // یہاں آپ بل سیو اور شیئر کرنے کا کوڈ لکھ سکتے ہیں
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.share, size: 20),
                              label: const Text(
                                'محفوظ کریں اور شیئر کریں',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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