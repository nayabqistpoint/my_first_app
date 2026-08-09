import 'package:flutter/material.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onSaveAndClose;
  final VoidCallback onSaveAndNew;

  const ActionButtonsWidget({
    super.key,
    required this.onSaveAndClose,
    required this.onSaveAndNew,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // پہلا بٹن: محفوظ کر کے بند کرنا
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onSaveAndClose,
              child: const Text(
                'محفوظ کریں',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // دوسرا بٹن: محفوظ کر کے اگلی آئٹم کے لیے فیلڈز خالی کرنا
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onSaveAndNew,
              child: const Text(
                'محفوظ اور نئی',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}