import 'package:flutter/material.dart';
import 'purchase_page_controller.dart';
import 'common/header_capsules.dart';
import 'common/party_selector_widget.dart';
import 'common/item_selector_row_widget.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  late final PurchasePageController controller;

  @override
  void initState() {
    super.initState();
    controller = PurchasePageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
                        PartySelectorWidget(
                          onPartySelected: (String? selectedPhone) {
                            controller.selectedPartyPhone = selectedPhone;
                          },
                        ),
                        const SizedBox(height: 8),
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
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
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