import 'package:flutter/material.dart';
import 'pay_now_body.dart';
import 'pay_now_controller.dart';
import '../../dashboard/widgets/source_selecter.dart';

class PayNowWidget extends StatelessWidget {
  final String customerMobileNumber;

  const PayNowWidget({
    super.key,
    required this.customerMobileNumber,
  });

  @override
  Widget build(BuildContext context) {
    // یہاں ہم نے کسٹمر کا موبائل نمبر کنٹرولر کو پاس کر دیا ہے تاکہ ڈیٹا بیس میں سیو ہو سکے
    payNowController.customerMobileNumber = customerMobileNumber;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "قسط ادا کریں",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "نایاب قسط پوائنٹ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. رقم والا خانہ (فکسڈ)
                  SizedBox(
                    height: 55,
                    child: TextField(
                      controller: payNowController.amountController,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      decoration: InputDecoration(
                        hintText: "رقم درج کریں",
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "PKR",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. رقم لکھنے پر ظاہر ہونے والے خانے
                  ListenableBuilder(
                    listenable: payNowController,
                    builder: (context, child) {
                      if (payNowController.enteredAmount <= 0) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: const PayNowBody(),
                          ),
                          const SizedBox(height: 12),
                          SourceSelecter(
                            defaultAmount: payNowController.enteredAmount,
                            onSplitPaymentChanged: (primaryBankSource, totalCash, totalBank, detailedSplits) {
                              // اسپلٹ پیمنٹ لاجک
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // نیچے "محفوظ کریں" کا بٹن
          Container(
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  payNowController.savePayment(context);
                },
                child: const Text(
                  "محفوظ کریں",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}