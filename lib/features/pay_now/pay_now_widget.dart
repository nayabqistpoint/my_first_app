import 'package:flutter/material.dart';
// ignore: unused_import
import 'pay_now_body.dart';
import 'pay_now_controller.dart';
import '../../dashboard/widgets/payment_source_card.dart';

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
        backgroundColor: Colors.green, // 🟢 گرین بیک گراؤنڈ
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
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14), // 🟢 گرین PKR
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.green, width: 2), // 🟢 گرین فوکس بارڈر
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

                          // پیمنٹ سورس کارڈ (GlobalKey کے ساتھ)
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
                  backgroundColor: Colors.green, // 🟢 گرین بٹن
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

// ==========================================
// PAY NOW BODY WIDGET
// ==========================================
class PayNowBody extends StatelessWidget {
  const PayNowBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. تفصیل والا خانہ (پہلا کنٹرولر)
        TextField(
          controller: payNowController.descriptionController,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: "تفصیل درج کریں (اختیاری)",
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.green, width: 2), // 🟢 گرین فوکس بارڈر
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
        ),
        const SizedBox(height: 12),

        // 2. ریکارڈنگ / پلے والا خانہ (دوسرا کنٹرولر) - ہدایات سمیت
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // بائیں طرف مدھم انسٹرکشنز اور ٹائتل تاکہ جگہ کم لے
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "آڈیو ریکارڈنگ (اختیاری)",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "اپنا نام، کل بقایا رقم اور ماہانہ قسط زبانی ریکارڈ کروائیں۔",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey, // مدھم رنگ تاکہ نمایاں نہ ہو لیکن پڑھا جا سکے
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // دائیں طرف مائیک کا بٹن
              IconButton(
                onPressed: () {
                  // آڈیو ریکارڈنگ یا پلے کرنے کی لاجک یہاں آئے گی
                },
                icon: const Icon(Icons.mic, color: Colors.green), // 🟢 گرین مائیک آئیکن
                tooltip: "آڈیو ریکارڈ کریں",
              ),
            ],
          ),
        ),
      ],
    );
  }
}