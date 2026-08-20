import 'package:flutter/material.dart';
import 'package:my_first_app/features/pay_now/pay_now_body.dart';
import 'package:my_first_app/features/pay_now/pay_now_controller.dart';
import 'package:my_first_app/dashboard/widgets/payment_source_card.dart';

class PayNowWidget extends StatefulWidget {
  final String customerMobileNumber;
  final double? initialAmount; // 🎯 ڈائیلاگ سے آٹو سلیکٹڈ رقم وصول کرنے کے لیے

  const PayNowWidget({
    super.key,
    required this.customerMobileNumber,
    this.initialAmount,
  });

  @override
  State<PayNowWidget> createState() => _PayNowWidgetState();
}

class _PayNowWidgetState extends State<PayNowWidget> {
  // ۱۔ PaymentSourceCard کی حالت حاصل کرنے کے لیے GlobalKey
  final GlobalKey<PaymentSourceCardState> _paymentCardKey = GlobalKey<PaymentSourceCardState>();

  String selectedPaymentSource = 'Cash';

  @override
  void initState() {
    super.initState();
    // 🎯 اگر ڈائیلاگ سے قسط کی رقم پاس ہوئی ہے تو فوراً فیلڈ اور کنٹرولر میں سیٹ کریں
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      final String formattedAmount = widget.initialAmount!.toStringAsFixed(0);
      payNowController.amountController.text = formattedAmount;
    }
  }

  @override
  Widget build(BuildContext context) {
    payNowController.customerMobileNumber = widget.customerMobileNumber;

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
                  // ۱۔ رقم درج کرنے کا خانہ
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

                  // ۲۔ رقم درج کرنے پر کھلنے والا حصہ
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

                          // پیمنٹ سورس کارڈ (GlobalKey اور اٹیچمنٹ کنکشن کے ساتھ)
                          PaymentSourceCard(
                            key: _paymentCardKey,
                            isAdmin: false,
                            selectedSource: selectedPaymentSource,
                            onChanged: (newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedPaymentSource = newValue;
                                });
                              }
                            },
                            // 🎯 یہ دو فیلڈز کنٹرولر کو تصویر اور ڈسکرپشن مہیا کریں گی
                            noteController: payNowController.descriptionController,
                            onAttachmentPicked: (path) {
                              payNowController.attachmentPath = path;
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

          // ۳۔ محفوظ کریں کا بٹن
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
                  final cardState = _paymentCardKey.currentState;
                  List<Map<String, dynamic>>? splitList;

                  if (cardState != null && cardState.isSplitMode) {
                    splitList = cardState.getSplitPaymentsList();
                  }

                  payNowController.savePayment(
                    context,
                    paymentSource: selectedPaymentSource,
                    splitPaymentsList: splitList,
                  );
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