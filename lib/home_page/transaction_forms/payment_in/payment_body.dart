import 'package:flutter/material.dart';
import 'payment_in_controller.dart';
import '../common/discount_widget.dart';
import '../../../dashboard/widgets/payment_source_card.dart';

class PaymentBody extends StatefulWidget {
  final PaymentInController controller;

  const PaymentBody({super.key, required this.controller});

  @override
  State<PaymentBody> createState() => _PaymentBodyState();
}

class _PaymentBodyState extends State<PaymentBody> {
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(widget.controller.amountFocusNode);
    });
  }

  // پرمیشن کی شرط اور ریکارڈنگ ہینڈلنگ
  Future<void> _handleAudioRecording() async {
    // ۱۔ اگر پہلے سے ریکارڈنگ جاری تھی اور صارف نے اب سٹاپ کا بٹن دبایا
    if (_isRecording) {
      setState(() {
        _isRecording = false;
      });
      // یہاں آپ کے پیکیج کا سٹاپ فنکشن ایکچوئل آڈیو سیو کر کے پاتھ لائے گا
      // widget.controller.audioPath = await audioRecorder.stop();
      return;
    }

    // ۲۔ پرمیشن کی حقیقی چیکنگ (جہاں تک پرمیشن نہ ملے ریکارڈنگ شروع نہیں ہوگی)
    bool hasPermission = await _checkMicrophonePermission();

    if (!hasPermission) {
      // پرمیشن نہیں ملی: صرف میسج دکھائیں اور UI کو بالکل مت چھیڑیں
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('مائیکروفون کی اجازت درکار ہے...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return; // پرمیشن نہ ملنے پر فنکشن یہی ختم ہو جائے گا، UI ریکارڈنگ موڈ میں نہیں جائے گی
    }

    // ۳۔ اگر اجازت مل جائے تب ہی UI تبدیل ہو اور ریکارڈنگ شروع ہو
    setState(() {
      _isRecording = true;
    });
    
    // یہاں آپ کے ایکچوئل ریکارڈر کا سٹارٹ فنکشن چلے گا
    // await audioRecorder.start();
  }

  // مائیک پرمیشن کا فنکشن (یہاں آپ کے پیکیج کا پرمیشن فنکشن استعمال ہوگا)
  Future<bool> _checkMicrophonePermission() async {
    // فی الحال پرمیشن نہ ہونے پر یہ false ریٹرن کر رہا ہے
    // جب آپ کا ایکچوئل آڈیو پیکیج (e.g., record, permission_handler) کنیکٹ ہوگا تو وہ سچی پرمیشن دے گا
    return false; 
  }

  // آڈیو ختم / ڈیلیٹ کرنے کا فنکشن
  void _clearAudio() {
    setState(() {
      _isRecording = false;
      widget.controller.audioPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ۱۔ تاریخ کی پٹی
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'تاریخ: 19 اگست 2026',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.calendar_today, size: 18, color: Colors.green[700]),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ۲۔ رقم (Amount) درج کرنے کا خانہ
          TextField(
            controller: widget.controller.amountController,
            focusNode: widget.controller.amountFocusNode,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'رقم درج کریں (Amount)',
              prefixText: 'Rs. ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ۳۔ رقم داخل کرنے کے بعد ظاہر ہونے والے وزٹس
          ValueListenableBuilder<bool>(
            valueListenable: widget.controller.hasAmountEntered,
            builder: (context, hasAmount, child) {
              if (!hasAmount) {
                return const SizedBox.shrink();
              }

              final bool hasAudioSaved = widget.controller.audioPath != null && widget.controller.audioPath!.isNotEmpty;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // وائس نوٹ / آڈیو ریکارڈر باکس
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: hasAudioSaved ? Colors.green : Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: hasAudioSaved ? Colors.green.shade50 : Colors.grey[50],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.mic, 
                              color: _isRecording ? Colors.red : (hasAudioSaved ? Colors.green : Colors.grey),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _isRecording
                                  ? 'ریکارڈنگ ہو رہی ہے...'
                                  : (hasAudioSaved ? 'وائس نوٹ حاصل ہو گیا ہے' : 'وائس نوٹ ریکارڈ کریں'),
                              style: TextStyle(
                                color: hasAudioSaved ? Colors.green[800] : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (hasAudioSaved && !_isRecording)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: _clearAudio,
                              ),
                            IconButton(
                              icon: Icon(
                                _isRecording ? Icons.stop : Icons.fiber_manual_record, 
                                color: Colors.red,
                              ),
                              onPressed: _handleAudioRecording,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ڈسکاؤنٹ وزٹ
                  DiscountWidget(
                    onDiscountChanged: (String categoryName, double discountValue, bool isPercentage) {
                      widget.controller.updateDiscount(categoryName, discountValue, isPercentage);
                    },
                  ),
                  const SizedBox(height: 16),

                  // پیمنٹ سورس ویجیٹ
                  PaymentSourceCard(
                    key: widget.controller.paymentSourceCardKey,
                    isAdmin: true,
                    selectedSource: widget.controller.selectedPaymentSource,
                    onChanged: (String? newSource) {
                      setState(() {
                        widget.controller.updateSelectedSource(newSource);
                      });
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}