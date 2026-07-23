import 'package:flutter/material.dart';

class TransactionSummaryWidget extends StatefulWidget {
  final double subTotal;
  final double discountAmount;
  final double grandTotal;
  final TextEditingController receivedController;
  final TextEditingController descriptionController;
  final VoidCallback? onAddPhotoPressed;
  final String? attachedPhotoName;

  const TransactionSummaryWidget({
    super.key,
    required this.subTotal,
    required this.discountAmount,
    required this.grandTotal,
    required this.receivedController,
    required this.descriptionController,
    this.onAddPhotoPressed,
    this.attachedPhotoName,
  });

  @override
  State<TransactionSummaryWidget> createState() => _TransactionSummaryWidgetState();
}

class _TransactionSummaryWidgetState extends State<TransactionSummaryWidget> {
  bool _isFullPaid = false;

  @override
  Widget build(BuildContext context) {
    final paidAmount = double.tryParse(widget.receivedController.text) ?? 0.0;
    final balance = (widget.grandTotal - paidAmount).clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. سب ٹوٹل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('سب ٹوٹل (Subtotal):', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('Rs ${widget.subTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          if (widget.discountAmount > 0) ...[
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ڈسکاؤنٹ (Discount):', style: TextStyle(fontSize: 11, color: Colors.red)),
                Text('- Rs ${widget.discountAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ],
          const Divider(height: 12),

          // 2. گرینڈ ٹوٹل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('کل قابلِ ادائیگی (Grand Total):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text('Rs ${widget.grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
            ],
          ),
          const SizedBox(height: 10),

          // 3. وصول / ادا شدہ رقم اور بائیں طرف فلو کے مطابق "فل پیڈ" باکس
          Row(
            children: [
              const Text('وصول / ادا شدہ:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const Spacer(),
              // فُل پیڈ چیک باکس (اب بالکل بائیں/درمیان میں فلو کے ساتھ ہے)
              InkWell(
                onTap: () {
                  setState(() {
                    _isFullPaid = !_isFullPaid;
                    if (_isFullPaid) {
                      widget.receivedController.text = widget.grandTotal.toStringAsFixed(0);
                    } else {
                      widget.receivedController.text = '';
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isFullPaid ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _isFullPaid ? Colors.green : Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isFullPaid ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 14,
                        color: _isFullPaid ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      const Text('فل پیڈ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // ان پٹ فیلڈ (بالکل دائیں طرف کارنر پر)
              SizedBox(
                width: 95,
                height: 34,
                child: TextField(
                  controller: widget.receivedController,
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() {
                      final entered = double.tryParse(val) ?? 0.0;
                      _isFullPaid = (entered == widget.grandTotal && widget.grandTotal > 0);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '0',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      borderSide: BorderSide(color: Color(0xFFE53935), width: 1.5),
                    ),
                  ),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 4. بقایا بیلنس (سیدھے فلو کے اندر)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('بقیہ رقم (Balance):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text('Rs ${balance.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: balance > 0 ? Colors.blue : Colors.black87)),
            ],
          ),
          const Divider(height: 12),

          // 5. ڈسکرپشن اور فوٹو باکس
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: widget.descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'نوٹس یا تفصیل لکھیں...',
                      hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        borderSide: BorderSide(color: Color(0xFFE53935), width: 1.5),
                      ),
                    ),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.onAddPhotoPressed,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 20, color: Color(0xFFE53935)),
                      SizedBox(height: 2),
                      Text('تصویر', style: TextStyle(fontSize: 8, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}