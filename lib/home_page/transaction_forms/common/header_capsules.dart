import 'dart:async';
import 'package:flutter/material.dart';

class HeaderCapsulesWidget extends StatefulWidget {
  final String invoiceNo;

  const HeaderCapsulesWidget({
    super.key,
    this.invoiceNo = 'INV-1001', // اگر انوائس نہ دی جائے تو ڈیفالٹINV-1001 رہے گا
  });

  @override
  State<HeaderCapsulesWidget> createState() => _HeaderCapsulesWidgetState();
}

class _HeaderCapsulesWidgetState extends State<HeaderCapsulesWidget> {
  late Timer _timer;
  late String _currentDate;
  late String _currentTime;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    // ہر سیکنڈ بعد لائیو ٹائم اپ ڈیٹ کرنے کے لیے
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final int hour =
        now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final String minute = now.minute.toString().padLeft(2, '0');
    final String second = now.second.toString().padLeft(2, '0');
    final String period = now.hour >= 12 ? "PM" : "AM";
    final String formattedTime = "$hour:$minute:$second $period";

    if (mounted) {
      setState(() {
        _currentDate = formattedDate;
        _currentTime = formattedTime;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. ریڈ ایپ بار والا حصہ
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          color: Colors.red.shade700,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'خریداری بل',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'نایاب قسط پوائنٹ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 2. تین چھوٹے کیپسولز والا حصہ (لائیو تاریخ اور وقت کے ساتھ)
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCapsule(title: 'انوائس #', value: widget.invoiceNo),
              const SizedBox(width: 6),
              _buildCapsule(title: 'تاریخ', value: _currentDate),
              const SizedBox(width: 6),
              _buildCapsule(title: 'وقت', value: _currentTime),
            ],
          ),
        ),
      ],
    );
  }

  // کیپسول بنانے کا ہیلپر
  Widget _buildCapsule({required String title, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade700, width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.red.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}