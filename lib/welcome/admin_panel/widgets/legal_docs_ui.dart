import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'legal_docs_controller.dart';
import 'agreement_helper.dart';
import 'guarantor_helper.dart';
import 'declaration_helper.dart'; // 🎯 آپ کی اصل اردو ڈیکلیریشن ہیلپر فائل

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
  final LegalDocsController _controller = LegalDocsController();
  Uint8List? _stampBytes;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🎯 ای اسٹامپ کے ہائپر لنک کے لیے فائل پیکر
  Future<void> _pickStamp() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result?.files.single.bytes != null) {
      setState(() => _stampBytes = result!.files.single.bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اسٹامپ اپ لوڈ ہو گیا!'), backgroundColor: Colors.green),
        );
      }
    }
  }

  Future<void> _handleHandover() async {
    bool ok = await _controller.completeHandover(widget.phone);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'موبائل تحویل میں دے دیا گیا!' : 'خرابی: ہینڈ اوور نہیں ہو سکا!'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
    if (ok && widget.onStateChanged != null) widget.onStateChanged!();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎯 ہیڈر + ای اسٹامپ اپ لوڈ کا ہائپر لنک
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gavel_rounded, color: Colors.blue.shade800, size: 18),
                      const SizedBox(width: 6),
                      Text('قانونی دستاویزات اور تحویل کا عمل',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                    ],
                  ),
                  InkWell(
                    onTap: _pickStamp,
                    child: Row(
                      children: [
                        Icon(_stampBytes != null ? Icons.check_circle : Icons.upload_file,
                            size: 14, color: _stampBytes != null ? Colors.green : Colors.blue.shade700),
                        const SizedBox(width: 3),
                        Text(
                          _stampBytes != null ? 'اسٹامپ اپ لوڈڈ' : 'ای اسٹامپ اپ لوڈ کریں',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _stampBytes != null ? Colors.green.shade800 : Colors.blue.shade700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),

              // 🎯 1. پرنٹنگ بٹنز
              const Text('1. ضروری دستاویزات جنریٹ کریں:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _btn(
                      label: 'معاہدہ اقساط',
                      color: Colors.indigo.shade700,
                      onPressed: () => AgreementHelper.generateAndPrintPdf(requestData: widget.requestData, phone: widget.phone),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _btn(
                      label: 'ضمانت نامہ',
                      color: Colors.teal.shade700,
                      onPressed: () => GuarantorHelper.generateAndPrintPdf(requestData: widget.requestData, phone: widget.phone),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _btn(
                      label: 'بیان حلفی',
                      color: Colors.deepOrange.shade700,
                      onPressed: () {
                        // 🎯 اپ کی اصل ڈیکلیریشن ہیلپر
                        DeclarationHelper.generateAndPrintPdf(
                          requestData: widget.requestData,
                          phone: widget.phone,
                          stampBytes: _stampBytes, // اپ لوڈ ہوا ہوگا تو پاس ہوگا، ورنہ null
                        );
                      },
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),

              // 🎯 2. فزیکل سیکیورٹیز چیکس
              const Text('2. تحویل سے پہلے فزیکل وصولی کی تصدیق:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              _chk('شناختی کارڈ کاپیاں (لازمی)', _controller.isCnicReceived, (v) => setState(() => _controller.isCnicReceived = v ?? false)),
              _chk('کاغذات پر دستخط مکمل ہیں (لازمی)', _controller.isDocsSigned, (v) => setState(() => _controller.isDocsSigned = v ?? false)),
              _chk('ایڈوانس رقم موصول ہو گئی', _controller.isAdvanceReceived, (v) => setState(() => _controller.isAdvanceReceived = v ?? false)),
              _chk('موبائل کا اصل ڈبہ موصول ہو گیا', _controller.isBoxReceived, (v) => setState(() => _controller.isBoxReceived = v ?? false)),
              _chk('فزیکل اسٹامپ پیپر و پرنوٹ موصول ہو گئے', _controller.isStampReceived, (v) => setState(() => _controller.isStampReceived = v ?? false)),
              _chk('فزیکل بینک چیکس موصول ہو گئے', _controller.isChequesReceived, (v) => setState(() => _controller.isChequesReceived = v ?? false)),
              const Divider(height: 16),

              // 🎯 3. تصویر اور نوٹس
              const Text('3. تحویل کی تصویر اور اضافی تفصیلات:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt, size: 14),
                    label: const Text('تصویر', style: TextStyle(fontSize: 10)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _controller.remarksController,
                      decoration: const InputDecoration(
                        hintText: 'نوٹس درج کریں...',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 🎯 4. فائنل ہینڈ اوور بٹن
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _controller.isReadyForHandover ? _handleHandover : null,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('موبائل کسٹمر کے حوالے کریں اور اکاؤنٹ مکمل کریں',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn({required String label, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 8)),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _chk(String title, bool val, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      activeColor: Colors.green.shade700,
      title: Text(title, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
      value: val,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}