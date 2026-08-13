import 'package:flutter/material.dart';

class LegalDocsUI extends StatefulWidget {
  final Map<String, dynamic> requestData;
  final String phone;
  final VoidCallback? onStateChanged;

  const LegalDocsUI({
    super.key,
    required this.requestData,
    required this.phone,
    this.onStateChanged,
  });

  @override
  State<LegalDocsUI> createState() => _LegalDocsUIState();
}

class _LegalDocsUIState extends State<LegalDocsUI> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: const Center(
        child: Text(
          "لیگل ڈاکومنٹس اور پی ڈی ایف وزٹ تیار ہے",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}