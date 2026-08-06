import 'package:flutter/material.dart';
import 'common/header_capsules.dart';
import 'common/party_selector_widget.dart';
import 'common/item_selector_row_widget.dart';
import 'common/discount_widget.dart';
import 'common/transaction_summary_widget.dart';

class PurchasePage extends StatelessWidget {
  const PurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const HeaderCapsulesWidget(),
                const SizedBox(height: 8),
                PartySelectorWidget(
                  onPartySelected: (selectedParty) {},
                ),
                const SizedBox(height: 8),
                ItemSelectorRowWidget(
                  onAddAnotherItem: () {},
                ),
                const SizedBox(height: 8),
                DiscountWidget(
                  onDiscountChanged: (discountValue, isPercentage) {},
                ),
                const SizedBox(height: 8),
                TransactionSummaryWidget(
                  subTotal: 0.0,
                  grandTotal: 0.0,
                  discountAmount: 0.0,
                  receivedController: TextEditingController(),
                  descriptionController: TextEditingController(),
                ),
              ],
            ),
          ),
        ),
      ),
      // اسکرین کے بالکل آخر میں فکسڈ ریڈ کلر کا محفوظ کریں بٹن (کلر اپڈیٹ کر کے گہرا ریڈ کر دیا گیا ہے)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.white,
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // کنٹرولر کا فنکشن یہاں سے کال ہوگا
            },
            child: const Text(
              'محفوظ کریں',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}