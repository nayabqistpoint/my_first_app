import 'package:flutter/material.dart';

class PartySelectorWidget extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final List<Map<String, String>> phoneContacts;
  final Function(String name, String phone) onNewPartyAdded;
  
  final String invoiceNo;
  final String currentDate;
  final String currentTime;

  const PartySelectorWidget({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.phoneContacts,
    required this.onNewPartyAdded,
    required this.invoiceNo,
    required this.currentDate,
    required this.currentTime,
  });

  @override
  State<PartySelectorWidget> createState() => _PartySelectorWidgetState();
}

class _PartySelectorWidgetState extends State<PartySelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ٹاپ کیپسولز (بل نمبر، تاریخ، وقت)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(flex: 2, child: Center(child: _buildCapsule('بل #: ${widget.invoiceNo}', 11))),
              const SizedBox(width: 6),
              Expanded(flex: 3, child: Center(child: _buildCapsule(widget.currentDate, 12, isCenter: true))),
              const SizedBox(width: 6),
              Expanded(flex: 2, child: Center(child: _buildCapsule(widget.currentTime, 11))),
            ],
          ),
          const SizedBox(height: 12),

          // 2. نام اور فون نمبر کی سیدھی فیلڈز
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: widget.nameController,
                    decoration: InputDecoration(
                      hintText: 'کسٹمر یا سپلائر کا نام درج کریں',
                      hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                      prefixIcon: const Icon(Icons.person, size: 18, color: Color(0xFFE53935)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // فون کانٹیکٹس سے چننے کے لیے پاپ اپ بٹن
              PopupMenuButton<Map<String, String>>(
                icon: const Icon(Icons.contacts, color: Color(0xFFE53935)),
                tooltip: 'فون کانٹیکٹس سے چنیں',
                onSelected: (contact) {
                  setState(() {
                    widget.nameController.text = contact['name'] ?? '';
                    widget.phoneController.text = contact['phone'] ?? '';
                  });
                },
                itemBuilder: (BuildContext context) {
                  if (widget.phoneContacts.isEmpty) {
                    return [
                      const PopupMenuItem(
                        enabled: false,
                        child: Text('کوئی کانٹیکٹ موجود نہیں', style: TextStyle(fontSize: 12)),
                      ),
                    ];
                  }
                  return widget.phoneContacts.map((contact) {
                    return PopupMenuItem(
                      value: contact,
                      child: Text(
                        '${contact['name']} (${contact['phone']})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3. فون نمبر کی فیلڈ
          SizedBox(
            height: 40,
            child: TextField(
              controller: widget.phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'موبائل نمبر درج کریں',
                hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                prefixIcon: const Icon(Icons.phone_android, size: 16, color: Color(0xFFE53935)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapsule(String text, double fontSize, {bool isCenter = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE53935), width: 1),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: isCenter ? FontWeight.bold : FontWeight.w600,
          color: const Color(0xFFE53935),
        ),
      ),
    );
  }
}