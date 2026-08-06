import 'package:flutter/material.dart';
import 'purchase_page_controller.dart';
import 'common/header_capsules.dart';
import 'common/party_selector_widget.dart';
import 'common/item_selector_row_widget.dart';
import 'common/discount_widget.dart';
import 'common/transaction_summary_widget.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  late final PurchasePageController controller;

  // ڈسکاؤنٹ کی اسٹیٹ
  double _discountValue = 0.0;
  bool _isDiscountPercentage = false;

  // ٹرانزیکشن سمری کے لیے کنٹرولرز
  final TextEditingController _receivedController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = PurchasePageController();
  }

  @override
  void dispose() {
    _receivedController.dispose();
    _descriptionController.dispose();
    controller.dispose();
    super.dispose();
  }

  // سب ٹوٹل اور ٹوٹل ڈسکاؤنٹ کا حساب
  double get _subTotal {
    double total = 0.0;
    for (var item in controller.itemsList) {
      final val = double.tryParse(item['subTotal'] ?? '0') ?? 0.0;
      total += val;
    }
    return total;
  }

  double get _calculatedDiscountAmount {
    if (_isDiscountPercentage) {
      return (_subTotal * _discountValue) / 100;
    }
    return _discountValue;
  }

  double get _grandTotal {
    final total = _subTotal - _calculatedDiscountAmount;
    return total < 0 ? 0.0 : total;
  }

  // سکرین ریفریش کرنے کا سموتھ ہیلپر
  Future<void> _openItemDetails(int index, {bool isEdit = false}) async {
    await controller.handleItemDetailNavigation(context, index, isEdit: isEdit);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const HeaderCapsulesWidget(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      children: [
                        // 1. پارٹی سلیکٹر
                        PartySelectorWidget(
                          onPartySelected: (String? selectedPhone) {
                            controller.selectedPartyPhone = selectedPhone;
                          },
                        ),
                        const SizedBox(height: 8),

                        // 2. آئٹم روز کی لسٹ
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.itemsList.length,
                          itemBuilder: (context, index) {
                            final item = controller.itemsList[index];

                            return ItemSelectorRowWidget(
                              itemName: item['itemName'] ?? '',
                              imeiNo: item['imeiNo'] ?? '',
                              subTotal: item['subTotal'] ?? '0.00',
                              calculationText: item['calculationText'] ?? '1 × 0',
                              onAddPressed: () {
                                bool isAdded = controller.addNewItemRow();
                                if (!isAdded) {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('برائے مہربانی پہلے آئٹم کا انتخاب کریں!'),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  setState(() {});
                                }
                              },
                              onDeletePressed: () {
                                if (controller.itemsList.length > 1) {
                                  setState(() {
                                    controller.removeItemRow(index);
                                  });
                                }
                              },
                              onEditPressed: () => _openItemDetails(index, isEdit: true),
                              onRowPressed: () => _openItemDetails(index, isEdit: false),
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        // 3. ڈسکاؤنٹ وجٹ
                        DiscountWidget(
                          onDiscountChanged: (discountValue, isPercentage) {
                            setState(() {
                              _discountValue = discountValue;
                              _isDiscountPercentage = isPercentage;
                            });
                          },
                        ),

                        const SizedBox(height: 10),

                        // 4. ٹرانزیکشن سمری وجٹ (درست پیرامیٹرز کے ساتھ)
                        TransactionSummaryWidget(
                          subTotal: _subTotal,
                          discountAmount: _calculatedDiscountAmount,
                          grandTotal: _grandTotal,
                          receivedController: _receivedController,
                          descriptionController: _descriptionController,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 5. محفوظ کرنے کا بٹن
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.savePurchase(),
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'محفوظ کریں',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}