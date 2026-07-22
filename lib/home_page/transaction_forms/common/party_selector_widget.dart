import 'package:flutter/material.dart';

class PartySelectorWidget extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final List<Map<String, String>> phoneContacts; // نام اور نمبر پر مشتمل کانٹیکٹس کی لسٹ
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
  bool _isAddingNew = false;

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Center(child: _buildCapsule('بل #: ${widget.invoiceNo}', 11)),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: Center(child: _buildCapsule(widget.currentDate, 12, isCenter: true)),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: Center(child: _buildCapsule(widget.currentTime, 11)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. موبائل کانٹیکٹس کے ساتھ اسمارٹ سرچ بار (نام یا نمبر سے تلاش)
          Row(
            children: [
              Expanded(
                child: Autocomplete<Map<String, String>>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Map<String, String>>.empty();
                    }
                    return widget.phoneContacts.where((contact) {
                      final name = contact['name']?.toLowerCase() ?? '';
                      final phone = contact['phone'] ?? '';
                      final query = textEditingValue.text.toLowerCase();
                      return name.contains(query) || phone.contains(query);
                    });
                  },
                  displayStringForOption: (option) => option['name'] ?? '',
                  onSelected: (Map<String, String> selection) {
                    // جیسے ہی کانٹیکٹ سلیکٹ ہوگا، نام اور فون نمبر دونوں آٹو فل ہو جائیں گے
                    widget.nameController.text = selection['name'] ?? '';
                    widget.phoneController.text = selection['phone'] ?? '';
                  },
                  // نیچے کھلنے والی کانٹیکٹس کی ڈراپ ڈاؤن لسٹ
                  optionsViewBuilder: (context, Function(Map<String, String>) onSelected, Iterable<Map<String, String>> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 80,
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final contact = options.elementAt(index);
                              return InkWell(
                                onTap: () => onSelected(contact),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        contact['name'] ?? '',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                                      ),
                                      Text(
                                        contact['phone'] ?? '',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    if (widget.nameController.text.isNotEmpty && controller.text.isEmpty) {
                      controller.text = widget.nameController.text;
                    }
                    controller.addListener(() {
                      widget.nameController.text = controller.text;
                    });

                    return SizedBox(
                      height: 40,
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'موبائل کانٹیکٹ سے نام یا نمبر تلاش کریں',
                          hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                          prefixIcon: const Icon(Icons.contacts, size: 18, color: Color(0xFFE53935)),
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
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // "نیا" ایڈ بٹن (اگر کانٹیکٹ میں نہیں ہے تو نیا بنانے کے لیے)
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isAddingNew = !_isAddingNew;
                    });
                  },
                  icon: Icon(_isAddingNew ? Icons.remove : Icons.person_add, size: 14, color: Colors.white),
                  label: Text(_isAddingNew ? 'بند' : 'نیا', style: const TextStyle(fontSize: 11, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            ],
          ),

          // 3. نیا کسٹمر ایڈ کرنے کی فیلڈ (موبائل نمبر)
          if (_isAddingNew) ...[
            const SizedBox(height: 10),
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
        ],
      ),
    );
  }

  // کیپسول ڈیزائن
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